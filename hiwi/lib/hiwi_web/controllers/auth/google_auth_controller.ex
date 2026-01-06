defmodule HiwiWeb.Auth.GoogleAuthController do
  use HiwiWeb, :controller

  alias Hiwi.Users

  # /auth/google
  def request(conn, _params) do
    conn
    |> Ueberauth.Plug.run(:google)
  end

  # /auth/google/callback
  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    email = auth.info.email
    fullname = auth.info.name || "Client"

    user =
      case Users.get_user_by_email(email) do
        nil ->
          {:ok, new_user} =
            Users.register_oauth_user(%{
              "email" => email,
              "fullname" => fullname
            })

          new_user

        existing_user ->
          existing_user
      end

    conn
    |> put_flash(:info, "Logged in with Google as #{user.email}")
    |> put_session(:user_id, user.id)
    |> redirect(to: "/queues")
  end

  # kalau gagal
  def callback(%{assigns: %{ueberauth_failure: _}} = conn, _params) do
    conn
    |> put_flash(:error, "Google OAuth failed.")
    |> redirect(to: "/auth/login")
  end
end
