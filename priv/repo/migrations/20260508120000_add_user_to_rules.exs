defmodule SpendTrack.Repo.Migrations.AddUserToRules do
  use Ecto.Migration

  def up do
    alter table(:rules) do
      add :user_id, references(:users, on_delete: :delete_all)
    end

    execute """
    UPDATE rules SET user_id = (SELECT id FROM users ORDER BY id ASC LIMIT 1)
    """

    alter table(:rules) do
      modify :user_id, :bigint, null: false
    end

    create index(:rules, [:user_id])
  end

  def down do
    drop index(:rules, [:user_id])

    alter table(:rules) do
      remove :user_id
    end
  end
end
