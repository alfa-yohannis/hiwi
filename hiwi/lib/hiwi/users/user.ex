defmodule Hiwi.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :fullname, :string
    field :email, :string
    field :hashed_password, :string

    field :password, :string, virtual: true, redact: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:fullname, :email, :password])
    |> validate_required([:fullname, :email, :password])
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 6)
    |> unique_constraint(:email)
    |> put_password_hash()
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
