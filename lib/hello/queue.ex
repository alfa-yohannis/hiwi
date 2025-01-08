defmodule Hello.Queue do
  use Ecto.Schema
  import Ecto.Changeset
  alias Hello.Repo
  alias Hello.Queue

  schema "queues" do
    field :name, :string
    field :status, :string
    field :description, :string
    field :prefix, :string
    field :max_number, :integer
    field :current_number, :integer
    field :create_user, :string
    field :update_user, :string
    belongs_to :user, Hello.User
    many_to_many :tellers, Hello.Tellers.Teller, join_through: "teller_queues"
    many_to_many :clients, Hello.Clients.Client, join_through: "client_queues"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(queue, attrs) do
    queue
    |> cast(attrs, [:name, :description, :status, :prefix, :max_number, :current_number, :create_user, :update_user])
    |> validate_required([:name, :prefix, :max_number])
  end
end
