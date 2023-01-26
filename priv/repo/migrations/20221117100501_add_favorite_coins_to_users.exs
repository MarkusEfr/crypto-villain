defmodule CryptoVillain.Repo.Migrations.AddFavoriteCoinsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :favorite_coins, {:array, :map}, default: [], null: false
    end
  end
end
