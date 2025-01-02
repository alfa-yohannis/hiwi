defmodule HelloWeb.DisplayOnlyLive do
  use HelloWeb, :live_view
  alias Hello.QueueCounter
  alias Hello.Queue
  alias Hello.Repo

  def mount(params, _session, socket) do

    %{"id" => queue_id} = params

    # Subscribe to updates from the QueueCounter
    :ok = Phoenix.PubSub.subscribe(Hello.PubSub, "queue_counter:updates:#{queue_id}")

    # Get the initial current number of cases handled from QueueCounter
    current_number = QueueCounter.get_current_number(queue_id)

    queue = Repo.get!(Queue, queue_id)

    socket =
      socket
      |> assign(:current_number, current_number)
      |> assign(:queue_name, queue.name)
      |> assign(:queue_prefix, queue.prefix)
      |> assign(:queue_id, queue_id)

    {:ok, socket, layout: false}
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
