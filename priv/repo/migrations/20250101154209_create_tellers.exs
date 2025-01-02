defmodule Hello.Repo.Migrations.CreateTellers do
  use Ecto.Migration

  def change do
    create table(:tellers) do
      add :name, :string, null: false
      add :username, :string, null: false
      add :hashed_password, :string, null: false
      add :queue_id, references(:queues, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:tellers, [:username])
  end
end
