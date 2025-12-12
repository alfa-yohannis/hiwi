defmodule HiwiWeb.Queue.QueueController do
    use HiwiWeb, :controller

    alias Hiwi.Queues
    alias Hiwi.QueueEntries
    alias Hiwi.Repo
    alias Hiwi.Users

    plug(
        HiwiWeb.Plugs.RequireAuth
        when action in [:show_registration_page, :show_edit_page, :register, :edit, :delete, :assign_teller, :remove_teller]
    )

    # Owner-only checks for modifying the queue include assign/remove here
    plug(:check_queue_owner when action in [:edit, :delete, :assign_teller, :remove_teller])

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

    def show_edit_page(conn, %{"id" => queue_id}) do
        queue =
            queue_id
            |> Queues.get_queue!()
            |> Repo.preload([:tellers, :owner]) # biar list teller kebaca

        # hanya owner yang boleh assign teller
        current_user = conn.assigns[:current_user]

        available_users =
            case current_user do
                %Hiwi.Users.User{role: :owner} ->
                Users.list_tellers_not_assigned_to(queue.id)

                _ ->
                []
            end

        changeset = Queues.build_edit_queue_changeset(queue)

        conn
        |> assign(:queue, queue)
        |> assign(:changeset, changeset)
        |> assign(:available_users, available_users)
        |> render(:edit)
    end

    def edit(conn, %{"id" => queue_id, "queue" => queue_params}) do
        old_queue = Queues.get_queue!(queue_id)
        case Queues.update_queue(old_queue, queue_params) do
            {:ok, _queue} ->
                conn
                |> put_flash(:info, "Queue updated successfully.")
                |> redirect(to: "/queues")

            {:error, changeset} ->
                # render :edit and pass required assigns so template doesn't crash
                conn
                |> assign(:queue, old_queue |> Repo.preload([:tellers, :owner]))
                |> assign(:changeset, changeset)
                |> assign(:available_users, []) # owner logic will produce actual list in show_edit_page
                |> render(:edit)
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
            {:ok, queue_entry} ->
                conn
                |> put_flash(:info, "Queue has been joined successfully.")
                |> redirect(to: ~p"/queues/entry/#{queue_entry.id}")

            {:error, %Ecto.Changeset{} = changeset} ->
                conn
                |> render(:join, changeset: changeset, queue_id: queue_id)
        end
    end

    def show_queue_entry_page(conn, %{"id" => entry_id}) do
        queue_entry = QueueEntries.get_queue_entry!(entry_id)
        render(conn, :entry, queue_entry: queue_entry)
    end

    # assign_teller expects POST /queues/:id/assign_teller with "user_id" form field
    def assign_teller(conn, %{"id" => queue_id, "user_id" => user_id_str}) do
        with {queue_id_i, ""} <- Integer.parse(to_string(queue_id)),
            {user_id_i, ""} <- Integer.parse(to_string(user_id_str)),
            {:ok, _} <- Queues.assign_teller_to_queue(queue_id_i, user_id_i) do

            conn
            |> put_flash(:info, "Teller added successfully.")
            |> redirect(to: "/queues/edit/#{queue_id}")
        else
            _ ->
                conn
                |> put_flash(:error, "Failed to add teller.")
                |> redirect(to: "/queues/edit/#{queue_id}")
        end
    end

    # remove_teller: DELETE /queues/:id/remove_teller/:user_id  (or POST _method=delete)
    def remove_teller(conn, %{"id" => queue_id, "user_id" => user_id_str}) do
        with {queue_id_i, ""} <- Integer.parse(to_string(queue_id)),
            {user_id_i, ""} <- Integer.parse(to_string(user_id_str)),
            {:ok, _} <- Queues.remove_teller_from_queue(queue_id_i, user_id_i) do

                conn
            |> put_flash(:info, "Teller removed.")
            |> redirect(to: "/queues/edit/#{queue_id}")
        else
            _ ->
                conn
                |> put_flash(:error, "Failed to remove teller.")
                |> redirect(to: "/queues/edit/#{queue_id}")
        end
    end
end
