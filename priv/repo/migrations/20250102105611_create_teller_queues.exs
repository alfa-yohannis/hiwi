defmodule Hello.Repo.Migrations.CreateTellerQueues do
  use Ecto.Migration

  def change do
    create table(:teller_queues) do
      add :teller_id, references(:tellers, on_delete: :delete_all), null: false
      add :queue_id, references(:queues, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:teller_queues, [:teller_id, :queue_id]) # Prevent duplicate relationships
  end
end
