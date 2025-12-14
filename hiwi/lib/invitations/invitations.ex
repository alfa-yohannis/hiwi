defmodule Hiwi.Invitations do
  import Ecto.Query
  alias Hiwi.Repo
  
  # PERBAIKAN: Menggunakan Hiwi.Users (bukan Accounts)
  alias Hiwi.Users 
  
  alias Hiwi.Invitations.Invitation
  alias Hiwi.Queues.QueueTeller

  def get_invitation_by_token(token) do
    Repo.get_by(Invitation, token: token)
    |> Repo.preload([:queue, :owner])
  end

  def invite_teller(queue, owner, invited_user_email) do
    # PERBAIKAN: Panggil fungsi dari modul Users
    user = Users.get_user_by_email(invited_user_email)

    cond do
      is_nil(user) -> {:error, :user_not_found}
      true ->
        token = :crypto.strong_rand_bytes(32) |> Base.url_encode64 |> binary_part(0, 32)
        
        %Invitation{}
        |> Invitation.changeset(%{
          queue_id: queue.id,
          owner_id: owner.id,
          invited_user_id: user.id,
          token: token,
          status: "pending"
        })
        |> Repo.insert()
    end
  end

  def respond_to_invitation(token, current_user, decision) do
    invitation = Repo.get_by(Invitation, token: token)

    cond do
      is_nil(invitation) -> {:error, :not_found}
      invitation.invited_user_id != current_user.id -> {:error, :forbidden}
      invitation.status != "pending" -> {:error, :already_responded}
      
      decision == "accepted" ->
        Ecto.Multi.new()
        |> Ecto.Multi.update(:invitation, Invitation.changeset(invitation, %{status: "accepted"}))
        |> Ecto.Multi.insert(:queue_teller, QueueTeller.changeset(%QueueTeller{}, %{
             user_id: current_user.id,
             queue_id: invitation.queue_id
           }))
        |> Repo.transaction()

      decision == "declined" ->
        invitation
        |> Invitation.changeset(%{status: "declined"})
        |> Repo.update()
        
      true -> {:error, :invalid_decision}
    end
  end
end