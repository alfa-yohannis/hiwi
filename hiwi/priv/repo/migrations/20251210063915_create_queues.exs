defmodule Hiwi.Repo.Migrations.CreateQueues do
  use Ecto.Migration

  def up do
    execute "CREATE TYPE queue_status AS ENUM ('active', 'inactive')"

    create table(:queues) do
      add :owner_id, references(:users, on_delete: :delete_all)

      add :name, :string, null: false
      add :description, :text
      add :prefix, :string, null: false

      add :current_number, :integer, default: 0, null: false
      add :max_number, :integer, default: 999, null: false

      add :status, :queue_status, default: "active", null: false

      timestamps(type: :utc_datetime)
    end

    create index(:queues, [:owner_id])
    create unique_index(:queues, [:prefix])
  end

  def down do
    drop table(:queues)

    execute "DROP TYPE queue_status"
  end
end
