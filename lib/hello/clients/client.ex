defmodule Hello.Clients.Client do
  use Ecto.Schema
  import Ecto.Changeset

  schema "clients" do
    field :full_name, :string
    field :email, :string
    field :phone_number, :string
    field :password, :string, virtual: true
    field :hashed_password, :string

    many_to_many :queues, Hello.Queue, join_through: "client_queues"

    timestamps()
  end

  @doc """
  A changeset for registering a client.
  """
  def changeset(client, attrs) do
    client
    |> cast(attrs, [:full_name, :email, :phone_number, :password, :hashed_password])
    |> validate_required([:full_name, :email, :phone_number, :hashed_password])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end
end
