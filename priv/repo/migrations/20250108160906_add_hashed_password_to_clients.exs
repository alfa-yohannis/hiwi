defmodule Hello.Repo.Migrations.AddHashedPasswordToClients do
  use Ecto.Migration

  def change do
    alter table(:clients) do
      add :hashed_password, :string
    end
  end
end
