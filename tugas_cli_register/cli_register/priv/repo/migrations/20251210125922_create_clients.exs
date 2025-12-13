defmodule CliRegister.Repo.Migrations.CreateClients do
  use Ecto.Migration

  def change do
    create table(:clients, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string, null: false
      add :queue_id, :string, null: false
      timestamps()
    end

    create unique_index(:clients, [:queue_id])
  end
end
