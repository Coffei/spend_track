defmodule SpendTrack.Repo.Migrations.AddUserToAccounts do
  use Ecto.Migration

  def change do
    alter table(:accounts) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
    end

    create index(:accounts, [:user_id])
  end
end
