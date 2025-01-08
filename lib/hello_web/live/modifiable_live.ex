defmodule HelloWeb.ModifiableLive do
  use HelloWeb, :live_view
  alias Hello.QueueCounter
  alias Hello.Queue
  import Ecto.Query
  alias Hello.Repo

  def mount(params, session, socket) do
    %{"id" => queue_id} = params

    case session do
      # Handle User session
      %{"user_id" => user_id} ->
        user = Repo.get!(Hello.User, user_id)
        queue = Repo.get!(Hello.Queue, queue_id) # Fetch queue from DB

        IO.inspect(queue.current_number, label: "Direct DB Fetch on Mount for User")

        socket =
          socket
          |> assign(:user, user)
          |> assign(:role, "Owner") # Explicitly assign the role
          |> assign(:user_id, user_id)
          |> assign(:queue, queue)
          |> assign(:queue_id, queue_id)
          |> assign(:current_number, queue.current_number) # Use DB value

        {:ok, socket, layout: {HelloWeb.Layouts, :live}}

      # Handle Teller session
      %{"teller_id" => teller_id} ->
        teller = Repo.get!(Hello.Tellers.Teller, teller_id)
        queue =
          Repo.one(
            from tq in Hello.Tellers.TellerQueue,
            join: q in assoc(tq, :queue),
            where: tq.teller_id == ^teller_id,
            where: q.id == ^queue_id,
            select: q
          )

        socket =
          socket
          |> assign(:user, teller)
          |> assign(:role, "Teller") # Explicitly assign the role
          |> assign(:user_id, teller_id)
          |> assign(:queue, queue)
          |> assign(:queue_id, queue.id)
          |> assign(:current_number, queue.current_number) # Use DB value

        {:ok, socket, layout: {HelloWeb.Layouts, :live}}

      # Handle no session
      _ ->
        {:ok,
        socket
        |> put_flash(:error, "You need to log in.")
        |> push_navigate(to: "/")}
    end
  end

  def handle_event("increment_number", _params, socket) do
    # IO.puts("HANDLE EVENT:")
    # IO.inspect(socket)
    queue_id = socket.assigns.queue_id
    old_queue = Repo.get!(Queue, queue_id)
    new_state = %{"current_number" => old_queue.current_number + 1}
    changeset = Queue.changeset(old_queue, new_state)
    Repo.update(changeset)

    current_queue = Repo.get!(Queue, queue_id)

    # Increment the current number
    new_number = current_queue.current_number

    # Update QueueCounter with the new number
    QueueCounter.set_current_number(queue_id, new_number)

    # Update the socket state with the new number
    socket =
      socket
      |> assign(:current_number, new_number)
      |> assign(:queue_id, queue_id)
    {:noreply,socket}

  end

  def handle_event("reset_to_zero", _, socket) do
    current_user = socket.assigns[:user]
    queue = socket.assigns[:queue]

    if current_user && current_user.id == queue.user_id do
      # Update the database
      Hello.Queues.update_queue_number(queue.id, 0)

      # Update the QueueCounter in-memory state
      QueueCounter.set_current_number(queue.id, 0)

      # Update the socket state
      {:noreply, assign(socket, :current_number, 0)}
    else
      {:noreply,
      socket
      |> put_flash(:error, "You are not authorized to reset this queue.")}
    end
  end

  def reset_to_zero(conn, %{"id" => queue_id}) do
    queue = HelloWeb.Queues.get_queue!(queue_id)

    # Check if the current user is the owner of the queue
    current_user = conn.assigns[:user]

    if current_user && current_user.id == queue.owner_id do
      # Update the queue's current number in the database
      HelloWeb.Queues.update_queue_number(queue_id, 0)

      # Reload the queue and redirect to its show page
      conn
      |> put_flash(:info, "Queue has been reset to zero.")
      |> redirect(to: ~p"/queues/#{queue_id}")
    else
      # Deny access if the user is not the owner
      conn
      |> put_flash(:error, "You are not authorized to reset this queue.")
      |> redirect(to: ~p"/queues")
    end
  end

  def handle_info({:number_update, queue_id, new_number}, socket) do
    # Update the socket state when a new number is broadcasted
    socket =
      socket
      |> assign(:current_number, new_number)
      |> assign(:queue_id, queue_id)
    {:noreply,socket}
  end
end
