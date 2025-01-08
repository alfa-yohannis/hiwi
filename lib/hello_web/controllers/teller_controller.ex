defmodule HelloWeb.TellerController do
  use HelloWeb, :controller

  alias Hello.Repo
  alias Hello.Queue
  import Ecto.Query
  alias Hello.Tellers
  alias Hello.Tellers.Teller
  alias HelloWeb.Router.Helpers, as: Routes
  alias Argon2

  @spec index(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def index(conn, _params) do
    tellers =
      Repo.all(
        from t in Teller,
          preload: [:queues] # Preload the many-to-many association
      )

    render(conn, :index, tellers: tellers)
  end

  def new(conn, _params) do
    changeset = Tellers.change_teller(%Teller{})
    queue_options = fetch_queue_options(conn)

    # Debug output
    IO.inspect(queue_options, label: "Queue Options in new/2")

    render(conn, :new, changeset: changeset, queue_options: queue_options, action: ~p"/tellers")
  end

  def create(conn, %{"teller" => teller_params}) do
    # Extract queue IDs and convert them to integers
    queue_ids =
      teller_params
      |> Map.get("queue_ids", [])
      |> Enum.map(&String.to_integer/1)

    # Hash the password or raise an error if it's missing
    hashed_password =
      case Map.get(teller_params, "password") do
        nil -> raise ArgumentError, "Password is required"
        password -> Argon2.hash_pwd_salt(password)
      end

    # Prepare teller parameters by replacing password with hashed password
    updated_teller_params =
      teller_params
      |> Map.put("hashed_password", hashed_password)
      |> Map.delete("password")

    # Attempt to create the teller with associated queues
    case Tellers.create_teller_with_queues(updated_teller_params, queue_ids) do
      {:ok, %{teller: _teller}} ->
        conn
        |> put_flash(:info, "Teller created successfully.")
        |> redirect(to: ~p"/tellers") # Redirect to the index page

      {:error, :teller, %Ecto.Changeset{} = changeset, _} ->
        queue_options = fetch_queue_options(conn)
        conn
        |> put_flash(:error, "Failed to create teller. Please review the errors below.")
        |> render(:new, changeset: changeset, queue_options: queue_options)

      {:error, :teller_queues, _reason, _} ->
        conn
        |> put_flash(:error, "Failed to associate teller with queues.")
        |> redirect(to: ~p"/tellers")
    end
  end

  def show(conn, %{"id" => id}) do
    teller = Tellers.get_teller!(id)
    render(conn, :show, teller: teller)
  end

  def edit(conn, %{"id" => id}) do
    teller = Tellers.get_teller!(id)
    changeset = Tellers.change_teller(teller)
    queue_options = fetch_queue_options(conn)  # Fetch queue options

    render(conn, :edit, teller: teller, changeset: changeset, queue_options: queue_options)
  end

  def update(conn, %{"id" => id, "teller" => teller_params}) do
    teller = Tellers.get_teller!(id)

    case Tellers.update_teller(teller, teller_params) do
      {:ok, teller} ->
        conn
        |> put_flash(:info, "Teller updated successfully.")
        |> redirect(to: ~p"/tellers/#{teller.id}")

      {:error, %Ecto.Changeset{} = changeset} ->
        queue_options = fetch_queue_options(conn)
        render(conn, :edit, teller: teller, changeset: changeset, queue_options: queue_options)
    end
  end

  def delete(conn, %{"id" => id}) do
    teller = Tellers.get_teller!(id)
    {:ok, _teller} = Tellers.delete_teller(teller)

    conn
    |> put_flash(:info, "Teller deleted successfully.")
    |> redirect(to: ~p"/tellers")
  end

  # Helper function to fetch queues for the logged-in user
  defp fetch_queues(conn) do
    if conn.assigns[:user] do
      Repo.all(from q in Queue, where: q.user_id == ^conn.assigns[:user].id)
    else
      []
    end
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
