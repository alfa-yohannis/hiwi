defmodule ClientRegistrationWeb.TellerController do
  use ClientRegistrationWeb, :controller

  def teller(conn, _params) do
    render(conn, :teller)
  end
end
