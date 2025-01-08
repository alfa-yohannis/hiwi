defmodule Hello.Queues do
  alias Hello.Repo
  import Ecto.Query
  alias Hello.Queue
  alias Hello.ClientQueues

  def update_queue_number(queue_id, new_number) do
    queue = Repo.get!(Queue, queue_id)

    changeset = Queue.changeset(queue, %{current_number: new_number})
    {:ok, updated_queue} = Repo.update(changeset)

    updated_queue
  end

  def fetch_client_queues(client_id) do
    Repo.all(
      from cq in ClientQueues,
      join: q in assoc(cq, :queue),
      where: cq.client_id == ^client_id,
      select: q
    )
  end
end
