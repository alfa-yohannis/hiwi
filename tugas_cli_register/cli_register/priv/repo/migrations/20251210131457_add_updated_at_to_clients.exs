defmodule CliRegister.Repo.Migrations.AddUpdatedAtToClients do
  use Ecto.Migration

  def change do
    alter table(:clients) do
      add :updated_at, :naive_datetime
    end
  end
end
