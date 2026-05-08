defmodule SpendTrack.Repo.Migrations.AddRuleToPayments do
  use Ecto.Migration

  def change do
    alter table(:payments) do
      add :rule_id, references(:rules, on_delete: :nilify_all)
    end

    create index(:payments, [:rule_id])
  end
end
