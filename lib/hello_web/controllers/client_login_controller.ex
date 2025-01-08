defmodule HelloWeb.ClientLoginController do
  use HelloWeb, :controller
  alias Hello.Clients
  alias Hello.Clients.Client

  # Render Client Login Form
  def index(conn, _params) do
    # Initialize an empty changeset
    changeset = Clients.change_client(%Client{})
    render(conn, "client_login.html", changeset: changeset)
  end

  # Handle Client Login
  def client_login(conn, %{"client" => params}) do
    case Clients.authenticate_client(params["email"], params["password"]) do
      {:ok, client} ->
        conn
        |> put_session(:client_id, client.id)
        |> assign(:user, %{id: client.id, email: client.email, role: "Client"})
        |> put_flash(:info, "Logged in successfully!")
        |> redirect(to: "/")

      :error ->
        changeset = Clients.change_client(%Client{})
        conn
        |> put_flash(:error, "Invalid email or password")
        |> render("client_login.html", changeset: changeset)
    end
  end
end
