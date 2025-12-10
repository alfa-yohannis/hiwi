defmodule Hiwi.Queues.Queue do
  use Ecto.Schema
  import Ecto.Changeset

  @queue_status [:active, :inactive]

  @required_fields [:owner_id, :name, :prefix, :max_number, :status]

  @optional_fields [:description]

  schema "queues" do
    field :name, :string
    field :description, :string
    field :prefix, :string

    field :current_number, :integer
    field :max_number, :integer

    field :status, Ecto.Enum, values: @queue_status
    belongs_to :owner, Hiwi.Users.User

    timestamps(type: :utc_datetime)
  end

  def changeset(queue, attrs) do
    queue
    |> cast(attrs, @required_fields ++ @optional_fields)

    |> validate_required(@required_fields)

    |> unique_constraint(:prefix)

    |> validate_number(:max_number, greater_than: 0)
    |> validate_change(:current_number, fn :current_number, value ->
        if is_integer(value) and value >= 0 do
            []
        else
            [current_number: "must be greater than or equal to 0"]
        end
      end)

    |> validate_length(:prefix, min: 1, max: 10)
    |> validate_length(:name, min: 3, max: 100)

    |> validate_format(:prefix, ~r/^[A-Z0-9]+$/)
  end
end
