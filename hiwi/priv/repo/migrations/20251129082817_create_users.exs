defmodule Hiwi.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def up do
    execute "CREATE TYPE user_role AS ENUM ('owner', 'teller')"

    create table(:users) do
      add :fullname, :string
      add :email, :string
      add :hashed_password, :string
      add :role, :user_role, default: "owner", null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email])
  end

  def down do
    drop table(:users)

    execute "DROP TYPE user_role"
  end
end
