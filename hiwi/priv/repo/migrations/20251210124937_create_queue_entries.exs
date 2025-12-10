defmodule Hiwi.Repo.Migrations.CreateQueueEntries do
  use Ecto.Migration

  def change do
    create table(:queue_entries) do
      add :queue_id, references(:queues, on_delete: :nothing)
      add :full_name, :string
      add :phone_number, :string
      add :email, :string
      add :qr_code, :string
      add :queue_number, :integer

      timestamps()
    end

    create index(:queue_entries, [:queue_id])
  end
end
