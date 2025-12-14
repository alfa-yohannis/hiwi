defmodule Hiwi.Repo.Migrations.RemoveTimestampsFromQueueTellers do
  use Ecto.Migration

  def change do
    alter table(:queue_tellers) do
      remove :inserted_at
      remove :updated_at
    end
  end
end
