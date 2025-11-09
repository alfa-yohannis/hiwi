defmodule Hiwi.Accounts do
  alias Hiwi.Accounts.User
  alias Hiwi.Repo
  import Ecto.Query, warn: false

  @doc """
  Registers a user. This function is called by UserController.
  """
  def register_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end
  
  # Anda juga akan membutuhkan fungsi untuk login nanti
  @doc """
  Gets a single user by id.
  """
  def get_user!(id), do: Repo.get!(User, id)
end
