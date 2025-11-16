defmodule Hiwi.Queues.Queue do
  use Ecto.Schema
  import Ecto.Changeset
  # Hapus alias Queue yang tidak perlu, karena kita ada di modul Queue
  # alias Hiwi.Queues.Queue 

  schema "queues" do
    field :name, :string
    field :description, :string
    field :prefix, :string
    field :max_number, :integer
    
    # Field ini punya nilai default
    field :current_number, :integer, default: 0 
    field :status, :string, default: "Inactive" 

    # === INI PERBAIKANNYA ===
    # Hapus tanda '#' untuk mengaktifkan kembali relasi ke User
    belongs_to :owner, Hiwi.Accounts.User 

    timestamps(type: :utc_datetime)
  end

  @doc false
  # === INI PERBAIKAN UTAMANYA ===
  # Mengganti %Queue{} (yang ambigu) dengan %__MODULE__{}
  # __MODULE__ secara otomatis merujuk ke Hiwi.Queues.Queue
  def changeset(%__MODULE__{} = queue, attrs) do
    queue
    # Memasukkan semua field yang dibutuhkan (termasuk owner_id)
    |> cast(attrs, [:name, :description, :prefix, :max_number, :owner_id, :current_number, :status])
    
    # HANYA mewajibkan field yang harus diisi oleh Owner
    |> validate_required([:name, :description, :prefix, :max_number, :owner_id]) 
    
    # Menambahkan validasi tambahan
    |> validate_number(:max_number, greater_than: 0)
    |> validate_number(:current_number, greater_than_or_equal_to: 0)
    |> validate_inclusion(:status, ["Active", "Inactive"]) # Membatasi nilai status
    
    # === INI PERBAIKAN PENTING KEDUA ===
    # Kita harus menambahkan foreign_key_constraint 
    # agar error database-nya lebih jelas jika owner_id tidak ada
    |> foreign_key_constraint(:owner_id) 
  end
end