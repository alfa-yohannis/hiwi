defmodule HelloWeb.LoginController do
  use HelloWeb, :controller
  alias Hello.Tellers
  alias Hello.Tellers.Teller

  # Render Teller Login Form
  def index(conn, _params) do
    # Initialize an empty changeset
    changeset = Tellers.change_teller(%Teller{})
    render(conn, "teller_login.html", changeset: changeset)
  end

  # Handle Teller Login
  def teller_login(conn, %{"teller" => params}) do
    case Tellers.authenticate_teller(params["username"], params["password"]) do
      {:ok, teller} ->
        conn
        |> put_session(:teller_id, teller.id)
        |> assign(:user, %{id: teller.id, username: teller.username, role: "Teller"})
        |> put_flash(:info, "Logged in successfully as Teller!")
        |> redirect(to: "/")

      :error ->
        # Re-render the form with an error message
        changeset = Tellers.change_teller(%Teller{})
        conn
        |> put_flash(:error, "Invalid username or password")
        |> render("teller_login.html", changeset: changeset)
    end
  end
end
