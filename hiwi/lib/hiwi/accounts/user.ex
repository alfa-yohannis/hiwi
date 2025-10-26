defmodule Hiwi.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  # CATATAN: Ini adalah placeholder sementara agar kompilasi berhasil.
  # Kode autentikasi dari Pow dihapus sementara.

  schema "users" do
    field :email, :string
    field :password_hash, :string # Kolom asli tempat password disimpan

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password_hash])
    |> validate_required([:email])
    |> unique_constraint([:email])
  end
end
