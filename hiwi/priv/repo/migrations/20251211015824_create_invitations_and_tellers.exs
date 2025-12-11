defmodule Hiwi.Repo.Migrations.CreateInvitationsAndTellers do
  use Ecto.Migration

  def change do
    # 1. Tabel Undangan
    create table(:invitations) do
      add :status, :string, default: "pending", null: false
      add :token, :string, null: false
      
      # Relasi (menggunakan on_delete: :delete_all agar bersih jika antrian dihapus)
      add :queue_id, references(:queues, on_delete: :delete_all), null: false
      add :owner_id, references(:users, on_delete: :delete_all), null: false
      add :invited_user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end
    create index(:invitations, [:token], unique: true)

    # 2. Tabel Teller (Siapa menjaga antrian mana)
    create table(:queue_tellers) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :queue_id, references(:queues, on_delete: :delete_all), null: false
      timestamps()
    end
    create unique_index(:queue_tellers, [:user_id, :queue_id])
  end
end