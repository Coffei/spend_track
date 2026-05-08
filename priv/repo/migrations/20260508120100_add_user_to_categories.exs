defmodule SpendTrack.Repo.Migrations.AddUserToCategories do
  use Ecto.Migration

  def up do
    alter table(:categories) do
      add :user_id, references(:users, on_delete: :delete_all)
    end

    execute """
    UPDATE categories SET user_id = (SELECT id FROM users ORDER BY id ASC LIMIT 1)
    """

    alter table(:categories) do
      modify :user_id, :bigint, null: false
    end

    create index(:categories, [:user_id])
  end

  def down do
    drop index(:categories, [:user_id])

    alter table(:categories) do
      remove :user_id
    end
  end
end
