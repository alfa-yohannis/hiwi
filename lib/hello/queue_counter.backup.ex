defmodule Hello.QueueCounterBackup do
  use GenServer

  alias Phoenix.PubSub

  # Initialize with the starting number of cases handled
  def init(initial_number) do
    {:ok, initial_number}
  end

  # Start the GenServer with an initial number of 0 cases handled
  def start_link(_) do
    GenServer.start_link(__MODULE__, 0, name: __MODULE__)
  end

  # Public API to get the current number of cases handled
  def get_current_number do
    GenServer.call(__MODULE__, :get_current_number)
  end

  # Public API to set the current number of cases handled
  @spec set_current_number(any()) :: :ok
  def set_current_number(new_number) do
    GenServer.cast(__MODULE__, {:set_current_number, new_number})
  end

  # Handle getting the current number
  def handle_call(:get_current_number, _from, current_number) do
    {:reply, current_number, current_number}
  end

  # Handle setting the current number and broadcasting the update
  def handle_cast({:set_current_number, new_number}, _current_number) do
    PubSub.broadcast(Hello.PubSub, "queue_counter:updates", {:number_update, new_number})
    {:noreply, new_number}
  end
end
