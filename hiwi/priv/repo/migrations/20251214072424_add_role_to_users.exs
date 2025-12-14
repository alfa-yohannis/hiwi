defmodule Hiwi.Repo.Migrations.AddRoleToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      # Menambahkan kolom role bertipe text/string
      add :role, :string, default: "client"
    end
  end
end
