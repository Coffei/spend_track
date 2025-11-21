defmodule SpendTrack.Repo.Migrations.RemoveCurrency do
  use Ecto.Migration

  def change do
    alter table(:payments) do
      remove :currency, :text, null: false
    end
  end
end
