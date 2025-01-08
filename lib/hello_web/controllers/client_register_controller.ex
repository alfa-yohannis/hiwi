defmodule HelloWeb.ClientRegisterController do
  use HelloWeb, :controller
  alias Hello.Repo
  alias Hello.Clients
  alias Hello.Queue
  import Ecto.Query
  alias Hello.Clients.Client

  # Render Client Register Form
  def new(conn, _params) do
    # Initialize an empty changeset
    changeset = Clients.change_client(%Client{})
    queue_options = fetch_queue_options(conn)

    render(conn, "client_register.html", changeset: changeset, queue_options: queue_options)
  end

  # Handle Client Register
  def create(conn, %{"client" => client_params}) do
    queue_ids =
      client_params
      |> Map.get("queue_ids", [])
      |> Enum.map(&String.to_integer/1)

    # Hash the password or raise an error if it's missing
    hashed_password =
      case Map.get(client_params, "password") do
        nil -> raise ArgumentError, "Password is required"
        password -> Argon2.hash_pwd_salt(password)
      end

    # Prepare teller parameters by replacing password with hashed password
    updated_client_params =
      client_params
      |> Map.put("hashed_password", hashed_password)
      |> Map.delete("password")

    case Clients.create_client_with_queues(updated_client_params, queue_ids) do
      {:ok, _client} ->
        conn
        |> put_flash(:info, "Client registered successfully!")
        |> redirect(to: "/login/client")

      {:error, :client, %Ecto.Changeset{} = changeset, _} ->
        conn
        |> put_flash(:error, "Failed to create client. Please review the errors below.")
        |> render("client_register.html", changeset: changeset, queue_options: fetch_queue_options(conn))

      {:error, :client_queues, _reason, _} ->
        conn
        |> put_flash(:error, "Failed to associate client with queues.")
        |> redirect(to: "/clients")
    end
  end

  # Helper function to fetch queues for the logged-in user
  defp fetch_queues(conn) do
    Repo.all(from q in Queue)
  end

  # Helper function to fetch the queue options for the select input
  defp fetch_queue_options(conn) do
    queues = fetch_queues(conn)

    if queues == [] do
      [{"No Queues Available", nil}]
    else
      Enum.map(queues, fn queue -> {queue.name, queue.id} end)
    end
  end
end
