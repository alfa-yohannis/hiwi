defmodule Hello.Repo.Migrations.CreateClients do
  use Ecto.Migration

  def change do
    create table(:clients) do
      add :full_name, :string
      add :email, :string
      add :phone_number, :string

      timestamps()
    end

    create unique_index(:clients, [:email])
  end
end
