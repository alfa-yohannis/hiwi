defmodule HelloWeb.ClientController do
  use HelloWeb, :controller
  alias Hello.Clients
  alias Hello.Clients.Client

  def new(conn, _params) do
    changeset = Clients.change_client(%Client{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"client" => client_params}) do
    case Clients.create_client(client_params) do
      {:ok, _client} ->
        conn
        |> put_flash(:info, "Client registered successfully.")
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, ".html", changeset: changeset)
    end
  end
end
