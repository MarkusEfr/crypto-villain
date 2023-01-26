defmodule CryptoVillain.ThresholdJob do
  use Oban.Worker,
    queue: :events,
    priority: 0,
    max_attempts: 3,
    tags: ["threshold"],
    unique: [period: 60]

  alias CryptoVillain.{Posts, Accounts, Threshold}

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"threshold" => %{"coin" => coin, "price" => price}, "user_id" => user_id}}) do
    params = %{
      content: "Cost of the #{coin} crossed line at #{Decimal.from_float(price)}!",
      user_id: user_id
    }

    with {:ok, _post} <- Posts.create_post(params, [:user]),
         user <- Accounts.get_user!(user_id),
         updated_user <- Accounts.clear_coin_threshold(user, coin),
         {:ok, _result} <- Threshold.broadcast_change({:ok, updated_user}, {:thresholds, :updated}) do

      :ok
    end
  end
end
