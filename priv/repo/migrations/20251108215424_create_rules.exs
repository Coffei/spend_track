defmodule SpendTrack.Repo.Migrations.CreateRules do
  use Ecto.Migration

  def change do
    create table(:rules) do
      add :name, :text, null: false
      add :category_id, references(:categories, on_delete: :delete_all), null: false
      add :counterparty_filter, :text
      add :note_filter, :text

      timestamps()
    end

    create index(:rules, [:category_id])
  end
end
