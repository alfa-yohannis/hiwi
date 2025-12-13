defmodule CliRegister.Client do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "clients" do
    field :name, :string
    field :queue_id, :string
    timestamps()
  end

  def changeset(client, attrs) do
    client
    |> cast(attrs, [:name, :queue_id])
    |> validate_required([:name, :queue_id])
    |> unique_constraint(:queue_id)
  end
end

