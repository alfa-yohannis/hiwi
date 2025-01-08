defmodule Hello.Repo.Migrations.CreateClientQueues do
  use Ecto.Migration

  def change do
    create table(:client_queues) do
      add :client_id, references(:clients, on_delete: :delete_all), null: false
      add :queue_id, references(:queues, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:client_queues, [:client_id, :queue_id]) # Prevent duplicate relationships
  end
end
