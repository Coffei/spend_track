defmodule SpendTrack.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string, null: false
      add :avatar_url, :string
      add :provider, :string, null: false
      add :uid, :string, null: false

      timestamps()
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:provider, :uid], name: :users_provider_uid_index)
  end
end
