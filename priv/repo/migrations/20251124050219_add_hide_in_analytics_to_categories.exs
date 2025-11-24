defmodule SpendTrack.Repo.Migrations.AddHideInAnalyticsToCategories do
  use Ecto.Migration

  def change do
    alter table(:categories) do
      add :hide_in_analytics, :boolean, default: false, null: false
    end
  end
end
