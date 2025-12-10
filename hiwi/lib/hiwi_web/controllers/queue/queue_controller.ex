defmodule HiwiWeb.Queue.QueueController do
  use HiwiWeb, :controller

  alias Hiwi.Queues
  alias Hiwi.QueueEntries

  plug(
    HiwiWeb.Plugs.RequireAuth
    when action in [:show_registration_page, :show_edit_page, :register, :edit, :delete]
  )

  plug(:check_queue_owner when action in [:edit, :delete])

  def index(conn, _params) do
    current_user = conn.assigns[:current_user]

    queues =
      case current_user do
        %Hiwi.Users.User{} = user when user.role == :owner ->
          Queues.list_queues_by_owner(user.id)

        _ ->
          Queues.list_active_queues()
      end

    render(conn, :index, queues: queues)
  end

  def show_registration_page(conn, _params) do
    changeset = Queues.build_new_queue_changeset()
    render(conn, :register, changeset: changeset)
  end

  def register(conn, %{"queue" => queue_params}) do
    owner_id = conn.assigns[:current_user].id

    case Queues.create_queue(owner_id, queue_params) do
      {:ok, _queue} ->
        conn
        |> put_flash(:info, "Queue created successfully.")
        |> redirect(to: ~p"/queues")

      {:error, changeset} ->
        conn
        |> put_flash(
          :error,
          "Failed to create the Queue. Please check the form and fix the errors."
        )
        |> render(:register, changeset: changeset)
    end
  end

  def show_edit_page(conn, %{"id" => queue_id}) do
    queue = Queues.get_queue!(queue_id)
    changeset = Queues.build_edit_queue_changeset(queue)

    render(conn, :edit, changeset: changeset, queue: queue)
  end

  def edit(conn, %{"id" => queue_id, "queue" => queue}) do
    old_queue = Queues.get_queue!(queue_id)
    changeset = Queues.build_edit_queue_changeset(old_queue, queue)

    case Queues.update_queue(old_queue, queue) do
      {:ok, _queue} ->
        conn
        |> put_flash(:info, "Queue updated successfully.")
        |> redirect(to: "/queues")

      {:error, changeset} ->
        render(conn, :show_edit_page, changeset: changeset, queue: queue)
    end
  end

  def delete(conn, %{"id" => queue_id}) do
    queue = Queues.get_queue!(queue_id)
    Queues.delete_queue(queue)

    conn
    |> put_flash(:info, "Queue deleted successfully.")
    |> redirect(to: "/queues")
  end

  def check_queue_owner(conn, _params) do
    %{params: %{"id" => queue_id}} = conn

    case Queues.get_queue!(queue_id) do
      %Hiwi.Queues.Queue{owner_id: owner_id} = _queue ->
        if owner_id == conn.assigns.current_user.id do
          conn
        else
          conn
          |> put_flash(:error, "You don't have permission to access this queue.")
          |> redirect(to: "/queues")
          |> halt()
        end

      nil ->
        conn
        |> put_flash(:error, "Queue not found.")
        |> redirect(to: "/queues")
        |> halt()
    end
  end

  def show_join_queue_page(conn, %{"id" => queue_id}) do
    changeset = QueueEntries.build_new_queue_entry_changeset()
    render(conn, :join, changeset: changeset, queue_id: queue_id)
  end

  def join(conn, %{"id" => queue_id, "queue_entry" => queue_entry}) do
    case QueueEntries.create_queue_entry(queue_entry, queue_id) do
      {:ok, _queue_entry} ->
        conn
        |> put_flash(:info, "Queue has been joined successfully.")
        |> redirect(to: ~p"/queues")

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> render(:join, changeset: changeset, queue_id: queue_id)
    end
  end
end
