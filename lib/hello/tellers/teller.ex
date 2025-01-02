defmodule Hello.Tellers.Teller do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tellers" do
    field :name, :string
    field :username, :string
    field :password, :string, virtual: true  # Virtual field for plain-text password
    field :hashed_password, :string         # Field for hashed password

    # Many-to-many relationship with queues
    many_to_many :queues, Hello.Queue, join_through: "teller_queues"

    timestamps()
  end

  @doc false
  def changeset(teller, attrs) do
    teller
    |> cast(attrs, [:name, :username, :password, :hashed_password])
    |> validate_required([:name, :username, :hashed_password])
    |> unique_constraint(:username)
  end
end
