defmodule Hiwi.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def up do
    # 1. HARUS ADA TIGA ROLE DI SINI
    execute "CREATE TYPE user_role AS ENUM ('owner', 'teller', 'client')"

    create table(:users) do
      add :fullname, :string
      add :email, :string
      add :hashed_password, :string
      
      # 2. DEFAULT HARUS 'client'
      add :role, :user_role, default: "client", null: false 

      timestamps(type: :utc_datetime)
    end
    # ...
  end
  # ...
end