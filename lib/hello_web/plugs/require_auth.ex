defmodule HelloWeb.Plugs.RequireAuth do
  import Plug.Conn
  alias Hello.Repo
  alias Hello.User

  def call(conn, _opts) do
    if user_id = get_session(conn, :user_id) do
      user = Repo.get(User, user_id)
      assign(conn, :current_user, user)
    else
      conn
      |> Phoenix.Controller.put_flash(:error, "You need to log in.")
      |> Phoenix.Controller.redirect(to: "/login")
      |> halt()
    end
  end
end
