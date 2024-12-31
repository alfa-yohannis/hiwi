defmodule ClientRegistrationWeb.ClientController do
  use ClientRegistrationWeb, :controller

  alias ClientRegistration.Accounts
  alias ClientRegistration.Accounts.Client

  def new(conn, _params) do
    changeset = Accounts.change_client(%Client{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"client" => client_params}) do
    case Accounts.create_client(client_params) do
      {:ok, client} ->
        conn
        |> put_flash(:info, "Client created successfully.")
        |> redirect(to: ~p"/clients/#{client}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    client = Accounts.get_client!(id)
    render(conn, :show, client: client)
  end
end
