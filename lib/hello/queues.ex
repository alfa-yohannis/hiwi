defmodule Hello.Queues do
  alias Hello.Repo
  alias Hello.Queue

  def update_queue_number(queue_id, new_number) do
    queue = Repo.get!(Queue, queue_id)

    changeset = Queue.changeset(queue, %{current_number: new_number})
    {:ok, updated_queue} = Repo.update(changeset)

    updated_queue
  end
end
