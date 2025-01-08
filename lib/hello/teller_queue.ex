defmodule Hello.Tellers.TellerQueue do
  use Ecto.Schema
  import Ecto.Changeset

  schema "teller_queues" do
    belongs_to :teller, Hello.Tellers.Teller
    belongs_to :queue, Hello.Queue

    timestamps()
  end

  @doc false
  def changeset(teller_queue, attrs) do
    teller_queue
    |> cast(attrs, [:teller_id, :queue_id])
    |> validate_required([:teller_id, :queue_id])
    |> unique_constraint([:teller_id, :queue_id])
  end
end
