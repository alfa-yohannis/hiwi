defmodule Hello.QueueCounter do
  use GenServer

  alias Hello.Repo
  alias Hello.Queue
  alias Phoenix.PubSub

  # Initialize with state from the database
  def init(initial_map_state) do
    IO.puts("## Initializing with database state")
    db_state = load_state_from_db()
    IO.inspect(db_state, label: "Database state on init")
    {:ok, db_state}
  end

  # Start the GenServer
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  # Load initial state from the database
  defp load_state_from_db do
    Repo.all(Queue)
    |> Enum.reduce(%{}, fn queue, acc ->
      Map.put(acc, queue.id, queue.current_number)
    end)
  end

  # Public API: Get current number for a queue
  def get_current_number(queue_id) do
    GenServer.call(__MODULE__, {:get_current_number, queue_id})
  end

  # Public API: Set current number for a queue
  def set_current_number(queue_id, new_number) do
    GenServer.cast(__MODULE__, {:set_current_number, queue_id, new_number})
  end

  # Handle getting the current number for a queue
  def handle_call({:get_current_number, queue_id}, _from, current_map_state) do
    IO.inspect(current_map_state, label: "Current in-memory state")
    current_number =
      Map.get_lazy(current_map_state, queue_id, fn ->
        # Fetch from database if not in memory
        case Repo.get(Queue, queue_id) do
          nil -> 0
          queue -> queue.current_number
        end
      end)
    {:reply, current_number, current_map_state}
  end

  # Handle setting the current number for a queue
  def handle_cast({:set_current_number, queue_id, new_number}, current_map_state) do
    updated_map_state = Map.put(current_map_state, queue_id, new_number)

    # Broadcast the update
    PubSub.broadcast(
      Hello.PubSub,
      "queue_counter:updates:#{queue_id}",
      {:number_update, queue_id, new_number}
    )

    {:noreply, updated_map_state}
  end
end
