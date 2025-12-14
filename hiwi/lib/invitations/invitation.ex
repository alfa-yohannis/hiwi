defmodule Hiwi.Invitations.Invitation do
  use Ecto.Schema
  import Ecto.Changeset

  # PERBAIKAN: Menggunakan Hiwi.Users.User
  alias Hiwi.Users.User
  alias Hiwi.Queues.Queue

  schema "invitations" do
    field :status, :string, default: "pending"
    field :token, :string

    belongs_to :queue, Queue
    belongs_to :owner, User
    belongs_to :invited_user, User, foreign_key: :invited_user_id

    timestamps()
  end

  def changeset(invitation, attrs) do
    invitation
    |> cast(attrs, [:status, :token, :queue_id, :owner_id, :invited_user_id])
    |> validate_required([:status, :token, :queue_id, :owner_id, :invited_user_id])
    |> unique_constraint(:token)
  end
end