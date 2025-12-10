defmodule Hiwi.QueueEntries do
  alias Hiwi.Repo
  alias Hiwi.QueueEntries.QueueEntry

  alias Ecto.Changeset

  def build_new_queue_entry_changeset(attrs \\ %{}) do
    %QueueEntry{}
    |> QueueEntry.changeset(attrs)
  end

  def create_queue_entry(attrs, queue_id) do
    attrs = Map.put(attrs, "queue_id", queue_id)

    %QueueEntry{}
    |> QueueEntry.changeset(attrs)
    |> Repo.insert()
  end
end
