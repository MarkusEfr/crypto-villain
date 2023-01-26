defmodule CryptoVillain.Repo.Migrations.CreateFollowings do
  use Ecto.Migration

  def change do
    create table(:followings) do
      add :user_id, references(:users, on_delete: :nothing)
      add :follow_user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:followings, [:user_id])
    create index(:followings, [:follow_user_id])
    create unique_index(:followings, [:user_id, :follow_user_id], name: :following_users_index)
  end
end
