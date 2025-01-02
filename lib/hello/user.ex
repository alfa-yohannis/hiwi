defmodule Hello.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :token, :string
    field :provider, :string
    field :role, :string, default: "user"

    has_many :queues, Hello.Queue

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :token, :provider, :role])
    |> validate_required([:email, :token, :provider])
    |> unique_constraint(:email)
  end
end
