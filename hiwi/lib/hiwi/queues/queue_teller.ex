defmodule Hiwi.Queues.QueueTeller do
  use Ecto.Schema
  import Ecto.Changeset
  
  # PERBAIKAN: Menggunakan Hiwi.Users.User
  alias Hiwi.Users.User
  alias Hiwi.Queues.Queue

  schema "queue_tellers" do
    belongs_to :user, User
    belongs_to :queue, Queue
    timestamps()
  end

  def changeset(queue_teller, attrs) do
    queue_teller
    |> cast(attrs, [:user_id, :queue_id])
    |> validate_required([:user_id, :queue_id])
    |> unique_constraint([:user_id, :queue_id])
  end
end