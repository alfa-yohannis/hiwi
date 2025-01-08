defmodule HelloWeb.Plugs.RequireAuth do
  import Plug.Conn
  import Phoenix.Controller

  alias HelloWeb.Router.Helpers, as: Routes

  def init(default), do: default

  def call(conn, _opts) do
    if conn.assigns[:user] do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access this page.")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end
end
