defmodule HelloWeb.QueueController do
  use HelloWeb, :controller
  alias Hello.Queue
  import Ecto.Query
  alias Hello.Repo
  alias Hello.ClientQueues

  plug HelloWeb.Plugs.RequireAuth when action in [:new, :create, :update, :edit, :delete]
  plug :check_queue_owner when action in [:update, :edit, :delete]

  def index(conn, _params) do
    user = conn.assigns[:user]

    if user do
      cond do
        user.role == "Client" ->
          # Fetch queues specific to the client
          queues = Repo.all(
            from cq in Hello.Clients.ClientQueue,
            join: q in assoc(cq, :queue),
            where: cq.client_id == ^user.id,
            select: q
          )
          render(conn, :client, queues: queues)

        user.role == "Owner" ->
          # Fetch queues owned by the owner
          queues = Repo.all(from q in Hello.Queue, where: q.user_id == ^user.id)
          render(conn, :index, queues: queues)

        user.role == "Teller" ->
          # Fetch queues assigned to the teller
          queues = Repo.all(
            from tq in Hello.Tellers.TellerQueue,
            join: q in assoc(tq, :queue),
            where: tq.teller_id == ^user.id,
            select: q
          )
          render(conn, :index, queues: queues)

        true ->
          # Default case for logged-in users without a specific role
          render(conn, :index, queues: [])
      end
    else
      # User is not logged in; render blank page or redirect
      render(conn, :index, queues: [])
    end
  end

  def show(conn, params) do
    %{"id" => queue_id} = params
    queue = Repo.get!(Queue, queue_id)
    current_number = queue.current_number
    render(conn, :show, queue: queue, current_number: current_number)

    # %{"id" => queue_id} = params
    # queue = Repo.get(Queue, queue_id)
    # changeset = Queue.changeset(queue, %{})
    # render(conn, :edit, changeset: changeset, queue: queue)
  end

  def new(conn, _params) do
    changeset = Queue.changeset(%Queue{}, %{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"queue" => queue_params}) do
    # Fetch the current user as an Ecto struct
    current_user = Repo.get!(Hello.User, conn.assigns[:user].id)

    # Build the association and create the changeset
    changeset =
      current_user
      |> Ecto.build_assoc(:queues)  # This requires `current_user` to be an Ecto struct
      |> Hello.Queue.changeset(queue_params)

    case Repo.insert(changeset) do
      {:ok, _queue} ->
        conn
        |> put_flash(:info, "Queue created successfully.")
        |> redirect(to: ~p"/")

      {:error, changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def edit(conn, params) do
    %{"id" => queue_id} = params

    queue = Repo.get(Queue, queue_id)

    # IO.puts("AAAA = " <> Kernel.inspect(queue_id))

    changeset = Queue.changeset(queue, %{})

    render(conn, :edit, changeset: changeset, queue: queue)
  end

  def update(conn, params) do
    %{"id" => queue_id, "queue" => queue} = params

    old_queue = Repo.get(Queue, queue_id)
    changeset = Queue.changeset(old_queue, queue)

    case Repo.update(changeset) do
      {:ok, _queue} ->
        conn
        |> put_flash(:info, "Queue updated successfully.")
        |> redirect(to: "/")

      {:error, changeset} ->
        render(conn, :edit, changeset: changeset, queue: queue)
    end
  end

  def delete(conn, params) do
    %{"id" => queue_id} = params
    queue = Repo.get!(Queue, queue_id)
    result = Repo.delete!(queue)

    IO.puts("BBBX = " <> Kernel.inspect(result))

    conn
    |> put_flash(:info, "Queue deleted successfully.")
    |> redirect(to: "/")
  end

  def check_queue_owner(conn, _params) do
    %{params: %{"id" => queue_id}} = conn
    queue = Repo.get(Queue, queue_id)

    if queue && queue.user_id == conn.assigns[:user].id do
      conn
    else
      conn
      |> put_flash(:error, "You are not authorized to edit this queue.")
      |> redirect(to: ~p"/queues")
      |> halt()
    end
  end
end
