defmodule SpendTrack.Repo.Migrations.CreatePayments do
  use Ecto.Migration

  def change do
    create table(:payments) do
      add :time, :utc_datetime, null: false
      add :amount, :numeric, null: false
      add :currency, :text, null: false
      add :note, :text
      add :counterparty, :text, null: false

      add :account_id, references(:accounts, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:payments, [:account_id])
    create index(:payments, [:time])
  end
end
