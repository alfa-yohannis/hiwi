defmodule Hello.Clients.ClientQueue do
  use Ecto.Schema
  import Ecto.Changeset

  schema "client_queues" do
    belongs_to :client, Hello.Clients.Client
    belongs_to :queue, Hello.Queue

    timestamps()
  end

  @doc false
  def changeset(teller_queue, attrs) do
    teller_queue
    |> cast(attrs, [:client_id, :queue_id])
    |> validate_required([:client_id, :queue_id])
    |> unique_constraint([:client_id, :queue_id])
  end
end
