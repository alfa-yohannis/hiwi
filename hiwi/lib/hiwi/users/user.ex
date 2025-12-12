defmodule Hiwi.Users.User do
    use Ecto.Schema
    import Ecto.Changeset

    @roles [:owner, :teller]

    schema "users" do
        field :fullname, :string
        field :email, :string
        field :hashed_password, :string
        field :role, Ecto.Enum, values: @roles

        field :password, :string, virtual: true, redact: true

        has_many :queues, Hiwi.Queues.Queue, foreign_key: :owner_id

        many_to_many :assigned_queues, Hiwi.Queues.Queue,
        join_through: "queue_tellers",
        join_keys: [user_id: :id, queue_id: :id]

        timestamps(type: :utc_datetime)
    end

    @doc false
    def registration_changeset(user, attrs) do
        user
        |> cast(attrs, [:fullname, :email, :password])
        |> validate_required([:fullname, :email, :password])

        |> put_change(:role, :owner)

        |> validate_format(:email, ~r/@/)
        |> validate_length(:password, min: 6)
        |> unique_constraint(:email)

        |> put_password_hash()
    end

    @doc false
    def login_changeset(user, attrs) do
        user
        |> cast(attrs, [:email, :password])
        |> validate_required([:email, :password])
    end

    defp put_password_hash(changeset) do
        case get_change(changeset, :password) do
        new_password when is_binary(new_password) ->
            hashed = Pbkdf2.hash_pwd_salt(new_password)
            put_change(changeset, :hashed_password, hashed)
        _ ->
            changeset
        end
    end
end
