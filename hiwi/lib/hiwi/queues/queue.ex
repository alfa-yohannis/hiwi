defmodule Hiwi.Queues.Queue do
  use Ecto.Schema
  import Ecto.Changeset
  alias Hiwi.Queues.Queue

  schema "queues" do
    field :name, :string
    field :description, :string
    field :prefix, :string
    field :max_number, :integer
    
    # 1. Field ini sekarang punya nilai default di tingkat aplikasi
    #    TIDAK PERLU divalidasi karena nilainya sudah pasti 0
    field :current_number, :integer, default: 0 
    field :status, :string, default: "Inactive" 

    # 2. Menggunakan belongs_to untuk relasi ke tabel users (punya Nopal)
    belongs_to :owner, Hiwi.Accounts.User # Asumsi namespace user adalah Hiwi.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%Queue{} = queue, attrs) do
    queue
    # Memasukkan semua field yang dibutuhkan (termasuk owner_id dan defaults)
    |> cast(attrs, [:name, :description, :prefix, :max_number, :owner_id, :current_number, :status])
    
    # HANYA mewajibkan field yang harus diisi oleh Owner (current_number dan status TIDAK WAJIB)
    |> validate_required([:name, :description, :prefix, :max_number, :owner_id]) 
    
    # Menambahkan validasi tambahan
    |> validate_number(:max_number, greater_than: 0)
    |> validate_number(:current_number, greater_than_or_equal_to: 0)
    |> validate_inclusion(:status, ["Active", "Inactive"]) # Membatasi nilai status
  end
end
