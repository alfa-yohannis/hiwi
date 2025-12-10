defmodule HiwiWeb.Queue.QueueController do
    use HiwiWeb, :controller

    alias Hiwi.Queues

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
          |> put_flash(:error, "Failed to create the Queue. Please check the form and fix the errors.")
          |> render(:register, changeset: changeset)
        end
    end
end
