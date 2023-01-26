defmodule CryptoVillain.CoinInfo do
  use Ecto.Schema
  import Ecto.Changeset
  alias CryptoVillain.Threshold

  @primary_key false
  embedded_schema do
    field :name, :string
    field :price, :float, virtual: true, default: nil
    field :is_favorite, :boolean, virtual: true, default: true
    field :threshold, :map, default: %{}
  end

  @doc false
  def changeset(%CryptoVillain.CoinInfo{} = coin, attrs \\ %{}) do
    coin
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  def change_threshold(%Threshold{} = threshold, attrs \\ %{}) do
    Threshold.changeset(threshold, attrs)
  end
end
