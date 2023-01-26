defmodule CryptoVillain.CoinsManager do
  use GenServer

  alias CryptoVillain.{CoinInfo, Accounts}

  @topic inspect(__MODULE__)

  def subscribe do
    Phoenix.PubSub.subscribe(CryptoVillain.PubSub, @topic)
  end

  def broadcast_change({:ok, result}, event) do
    Phoenix.PubSub.broadcast(CryptoVillain.PubSub, @topic, {__MODULE__, event, result})
    {:ok, result}
  end

  def broadcast_change({:error, changeset}, _event), do: {:error, changeset}

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def merge(payload) do
    GenServer.cast(__MODULE__, {:merge, payload})
    |> threshold_crossing()

    {:ok, payload}
  end

  def get_state, do: GenServer.call(__MODULE__, :get_state)

  @impl true
  def init(_) do
    {:ok, %{}}
  end

  @impl true
  def handle_cast({:merge, payload}, coins) do
    cast_result = Map.merge(coins, payload)

    {:noreply, cast_result}
  end

  @impl true
  def handle_call(:get_state, _from, coins) do
    {:reply, transform(coins), coins}
  end

  def threshold_crossing(_) do
    threshold_coins = Accounts.list_users_threshold()

    Enum.each(get_state(), fn state_coin ->
      Enum.each(threshold_coins, fn threshold ->
        {user_id, threshold_coin} = {elem(threshold, 0), elem(threshold, 1)}
        match_result = {state_coin, threshold_coin} |> state_threshold_match()

        if match_result in [:crossing_more_equal, :crossing_less_equal] do
          %{user_id: user_id, threshold: threshold_coin}
          |> CryptoVillain.ThresholdJob.new()
          |> Oban.insert()
        end
      end)
    end)
  end

  defp state_threshold_match({state_coin, threshold_coin}) do
    if state_coin.name == threshold_coin.coin do
      case threshold_coin.operation do
        "<=" -> if elem(Float.parse(state_coin.price),0) <= threshold_coin.price, do: :crossing_less_equal
        ">=" -> if elem(Float.parse(state_coin.price),0) >= threshold_coin.price, do: :crossing_more_equal
        _ -> raise "Unexpected threshold operation"
      end
    end
  end

  defp transform(coins), do: Enum.map(coins, fn {k, v} -> %CoinInfo{name: k, price: v, is_favorite: false} end)
end
