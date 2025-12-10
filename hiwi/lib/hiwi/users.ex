defmodule Hiwi.Users do
  import Ecto.Query, warn: false

  alias Hiwi.Repo
  alias Hiwi.Users.User

  def register_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def build_registration_changeset() do
    User.registration_changeset(%User{}, %{})
  end

  def build_login_changeset() do
    User.login_changeset(%User{}, %{})
  end

  def authenticate_user(email, password) do
    user = Repo.get_by(User, email: email)

    cond do
      user && Pbkdf2.verify_pass(password, user.hashed_password) ->
        {:ok, user}

      user ->
        {:error, :unauthorized}

      true ->
        Pbkdf2.no_user_verify()
        {:error, :not_found}
    end
  end
end
