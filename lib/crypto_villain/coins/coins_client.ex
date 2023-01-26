defmodule CryptoVillain.CoinsClient do
  use WebSockex

  alias CryptoVillain.CoinsManager

  @server "wss://ws.coincap.io/prices?assets=ALL"
  def start_link(user_code) do
    WebSockex.start_link(@server, __MODULE__, user_code, name: via(user_code))
  end

  def run_listener(user_code) do
    DynamicSupervisor.start_child(CryptoVillain.Supervisor.CoinsClient, {__MODULE__, [user_code]})
  end

  def handle_frame({:text, msg}, state) do
    msg
    |> Jason.decode!()
    |> CoinsManager.merge()
    |> CoinsManager.broadcast_change({:coins, :merged})

    {:ok, state}
  end

  def child_spec(user_code) do
    %{
      id: {__MODULE__, user_code},
      start: {__MODULE__, :start_link, [user_code]}
    }
  end

  def via(user_code) do
    {:via, Registry, {CryptoVillain.CoinsClientRegistry, user_code}}
  end
end
