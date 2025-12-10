defmodule Hiwi.QueueEntries.QueueEntry do
  use Ecto.Schema
  import Ecto.Changeset

  schema "queue_entries" do
    field(:full_name, :string)
    field(:phone_number, :string)
    field(:email, :string)
    field(:qr_code, :string)
    field(:queue_number, :integer)

    belongs_to(:queue, Hiwi.Queues.Queue)

    timestamps(type: :utc_datetime)
  end

  def changeset(queue, attrs) do
    queue
    |> cast(attrs, [:full_name, :phone_number, :email, :queue_id, :qr_code, :queue_number])
    |> validate_required([:full_name, :phone_number, :email, :queue_id])
    |> validate_format(:email, ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/)
    |> validate_format(:phone_number, ~r/^[0-9]{10,13}$/)
    |> validate_length(:full_name, min: 3, max: 100)
    |> validate_length(:phone_number, min: 10, max: 13)
    |> validate_length(:email, min: 3, max: 100)
  end
end
