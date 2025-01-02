defmodule HelloWeb.QueueController do
  use HelloWeb, :controller
  alias Hello.Queue
  import Ecto.Query
  alias Hello.Repo

  plug HelloWeb.Plugs.RequireAuth when action in [:new, :create, :update, :edit, :delete]
  plug :check_queue_owner when action in [:update, :edit, :delete]

  def index(conn, _params) do
    IO.inspect(conn.assigns)

    queues = Repo.all(Queue)
    render(conn, :index, queues: queues)
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
    current_user = conn.assigns[:user]

    changeset =
      current_user
      |> Ecto.build_assoc(:queues)  # Sets `user_id`
      |> Queue.changeset(queue_params)

    case Repo.insert(changeset) do
      {:ok, _queue} ->
        conn
        |> put_flash(:info, "Queue created successfully.")
        |> redirect(to: ~p"/")  # Use the ~p sigil for paths

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
