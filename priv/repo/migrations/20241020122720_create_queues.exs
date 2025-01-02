defmodule Hello.Repo.Migrations.CreateQueues do
  use Ecto.Migration

  def down do
    drop_if_exists table(:queues)
  end

  def change do
    # Drop the table if it already exists
    drop_if_exists table(:queues)

    create table(:queues) do
      add :name, :string, null: false
      add :description, :text, null: true
      add :status, :string, null: false
      add :prefix, :string, null: false, default: "A"
      add :max_number, :integer, null: false, default: 100
      add :current_number, :integer, null: false, default: 1
      add :create_user, :string, null: true
      add :update_user, :string, null: true

      timestamps(type: :utc_datetime)
    end

  end
end
