defmodule HelloWeb.AuthController do
  use HelloWeb, :controller
  plug Ueberauth
  alias Hello.User
  alias Hello.Repo

  def callback(conn, params) do
    IO.puts("AAAAAA")
    IO.inspect(conn)
    IO.puts("BBBBBB")
    IO.inspect(params)
    IO.puts("CCCCCC")
    %{"code" => _code, "provider" => provider, "state" => _state} = params
    %{assigns: %{ueberauth_auth: auth}} = conn
    %{credentials: %{token: token}, info: %{email: email, nickname: nickname}} = auth

    user_params = %{
      token: token,
      email: email || nickname,
      provider: provider
    }

    IO.puts("DDDDD")
    IO.inspect(user_params)

    changeset = User.changeset(%User{}, user_params)

    signin(conn, changeset)
  end

  def signout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> put_flash(:info, "Signout has been successful.")
    |> redirect(to: "/")
  end

  defp signin(conn, changeset) do
  case insert_or_update_user(changeset) do
    {:ok, user} ->
      # Check if the user is logging in via GitHub and assign the role
      user =
        if changeset.changes[:provider] == "github" && changeset.changes[:email] == "NDKS20" do
          assign_role_to_owner(user)
        else
          assign_role_to_user(user)
        end

      conn
      |> put_flash(:info, "Good to see you again!")
      |> put_session(:user_id, user.id)
      |> put_session(:user_token, user.token)
      |> redirect(to: "/")
    {:error, reason} ->
      conn
      |> put_flash(:error, "Error when signing in: #{reason}")
      |> redirect(to: "/")
  end
  end

  defp assign_role_to_owner(user) do
    case update_user_role(user, "owner") do
      {:ok, updated_user} -> updated_user
      _ -> user
    end
  end

  defp assign_role_to_user(user) do
    case update_user_role(user, "user") do
      {:ok, updated_user} -> updated_user
      _ -> user
    end
  end

  defp insert_or_update_user(changeset) do
    case Repo.get_by(User, email: changeset.changes[:email]) do
      nil ->
        Repo.insert(changeset)

      user ->
        # Update the user's token and provider if they already exist
        user
        |> User.changeset(changeset.changes)
        |> Repo.update()
    end
  end

  def update_user_role(user, role) do
    user
    |> User.changeset(%{role: role})
    |> Repo.update()
  end
end
