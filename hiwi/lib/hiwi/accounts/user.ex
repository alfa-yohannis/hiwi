defmodule Hiwi.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  # === INI PERBAIKANNYA (YANG HILANG) ===
  # Kita butuh `Pbkdf2` (dari library pbkdf2_elixir), BUKAN `Comeonin.Pbkdf2`
  # Modul ini ada karena Anda sudah install `pbkdf2_elixir` di mix.exs [cite: hiwi/mix.exs]
  alias Pbkdf2

  schema "users" do
    # Field yang dibutuhkan untuk registrasi (sesuai README)
    field :full_name, :string
    field :phone_number, :string
    
    # Field dari kode Nopal (untuk Pbkdf2)
    field :email, :string
    field :hashed_password, :string
    field :password, :string, virtual: true, redact: true
    field :password_confirmation, :string, virtual: true, redact: true
    field :confirmed_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc """
  Changeset untuk registrasi user baru (USR-REG Nopal).
  INI JUGA PERBAIKANNYA: Menambahkan full_name, phone_number, password_confirmation
  """
  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:full_name, :phone_number, :email, :password, :password_confirmation])
    |> validate_required([:full_name, :phone_number, :email, :password, :password_confirmation])
    |> validate_format(:email, ~r/@/i)
    |> validate_length(:password, min: 8, max: 72)
    |> validate_confirmation(:password)
    |> unsafe_validate_unique(:email, Hiwi.Repo)
    |> unique_constraint(:email)
    |> put_hashed_password() # Memanggil fungsi internal di bawah
  end

  # --- Fungsi Internal untuk Password Hashing (dari kode Nopal) ---

  defp put_hashed_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        # Memanggil alias `Pbkdf2` (yang sudah benar)
        put_change(changeset, :hashed_password, Pbkdf2.hash_pwd_salt(password))

      _ ->
        changeset
    end
  end

  @doc """
  Verifikasi password (dari kode Nopal).
  """
  def valid_password?(%Hiwi.Accounts.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    # Memanggil alias `Pbkdf2` (yang sudah benar)
    Pbkdf2.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Pbkdf2.no_user_verify() # Memanggil alias `Pbkdf2` (yang sudah benar)
    false
  end
end