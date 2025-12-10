defmodule Hiwi.QueueEntries do
  alias Hiwi.Repo
  alias Hiwi.QueueEntries.QueueEntry

  alias Ecto.Changeset

  def build_new_queue_entry_changeset(attrs \\ %{}) do
    %QueueEntry{}
    |> QueueEntry.changeset(attrs)
  end

  def create_queue_entry(attrs, queue_id) do
    import Ecto.Query

    # Calculate next queue number
    query = from q in QueueEntry, where: q.queue_id == ^queue_id, select: max(q.queue_number)
    max_number = Repo.one(query) || 0
    next_number = max_number + 1

    attrs = attrs
    |> Map.put("queue_id", queue_id)
    |> Map.put("queue_number", next_number)

    result =
      %QueueEntry{}
      |> QueueEntry.changeset(attrs)
      |> Repo.insert()

    case result do
      {:ok, entry} ->
        path = generate_qr(entry.id)

        entry
        |> QueueEntry.changeset(%{qr_code: path})
        |> Repo.update()

      error ->
        error
    end
  end

  def generate_qr(entry_id) do
    base = HiwiWeb.Endpoint.url()
    endpoint = "#{base}/queues/entry/#{entry_id}"

    # Ensure directory exists
    dir = "priv/static/qr_codes"
    File.mkdir_p!(dir)

    file_path = "#{dir}/#{entry_id}.png"

    QRCode.create(endpoint, :medium)
    |> QRCode.render(:png)
    |> QRCode.save(file_path)

    "/qr_codes/#{entry_id}.png"
  end

  def get_queue_entry!(id) do
    Repo.get!(QueueEntry, id)
    |> Repo.preload(:queue)
  end
end
