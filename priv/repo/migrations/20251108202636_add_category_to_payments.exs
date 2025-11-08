defmodule SpendTrack.Repo.Migrations.AddCategoryToPayments do
  use Ecto.Migration

  def change do
    alter table(:payments) do
      add :category_id, references(:categories, on_delete: :nilify_all)
    end

    create index(:payments, [:category_id])
  end
end
