defmodule CryptoVillain.Threshold do
  defstruct [:coin, :operation, :price]
  @types %{coin: :string, operation: :string, price: :float}

  import Ecto.Changeset
  alias CryptoVillain.Threshold

  @topic inspect(__MODULE__)

  def subscribe do
    Phoenix.PubSub.subscribe(CryptoVillain.PubSub, @topic)
  end

  def broadcast_change({:ok, result}, event) do
    Phoenix.PubSub.broadcast(CryptoVillain.PubSub, @topic, {__MODULE__, event, result})
    {:ok, result}
  end

  def broadcast_change({:error, changeset}, _event), do: {:error, changeset}

  def changeset(%Threshold{} = threshold, attrs) do
    {threshold, @types}
    |> cast(attrs, Map.keys(@types))
    |> validate_required([:coin, :operation, :price])
    |> validate_inclusion(:operation, ["<=", ">="])
    |> validate_number(:price, greater_than: 0)
  end
end
