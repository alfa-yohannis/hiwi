defmodule Hello.Repo.Migrations.RemoveQueueIdFromTellers do
  use Ecto.Migration

  def change do
    alter table(:tellers) do
      remove :queue_id
    end
  end
end
