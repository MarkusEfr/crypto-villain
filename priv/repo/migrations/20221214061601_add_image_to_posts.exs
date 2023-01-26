defmodule CryptoVillain.Repo.Migrations.AddImageToPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :image, :string
    end
  end
end
