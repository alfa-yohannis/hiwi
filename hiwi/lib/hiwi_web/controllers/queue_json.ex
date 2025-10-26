defmodule HiwiWeb.QueueJSON do
  alias Hiwi.Queues.Queue

  @doc """
  Renders a list of queues.
  """
  def index(%{queues: queues}) do
    %{data: for(queue <- queues, do: data(queue))}
  end

  @doc """
  Renders a single queue.
  """
  def show(%{queue: queue}) do
    %{data: data(queue)}
  end

  defp data(%Queue{} = queue) do
    %{
      id: queue.id,
      name: queue.name,
      description: queue.description,
      prefix: queue.prefix,
      max_number: queue.max_number,
      current_number: queue.current_number,
      status: queue.status
    }
  end
end
