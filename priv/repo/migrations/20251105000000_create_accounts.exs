defmodule SpendTrack.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :name, :text, null: false
      add :color, :text, null: false

      timestamps()
    end
  end
end
