defmodule Hiwi.Users.User do
    use Ecto.Schema
    import Ecto.Changeset

    # 1. PERBAIKAN: Tambahkan :client ke daftar role yang valid
    @roles [:owner, :teller, :client]

    schema "users" do
        field :fullname, :string
        field :email, :string
        field :hashed_password, :string
        
        # 2. PERBAIKAN: Tambahkan nilai default :client
        field :role, Ecto.Enum, values: @roles, default: :client

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

        # Baris yang dihapus/diberi komentar:
        # |> put_change(:role, :owner) 

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

    # --- FUNGSI CHANGESET BARU UNTUK UPDATE ROLE ---
    # FUNGSI INI HARUS DI SINI, DI LUAR FUNGSI LAIN
    def role_changeset(user, attrs) do
        user
        |> cast(attrs, [:role])
        |> validate_required([:role]) 
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