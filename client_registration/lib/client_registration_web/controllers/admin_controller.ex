defmodule ClientRegistrationWeb.AdminController do
  use ClientRegistrationWeb, :controller

  def admin(conn, _params) do
    render(conn, :admin)
  end
end
