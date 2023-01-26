defmodule CryptoVillain.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      CryptoVillain.Repo,
      # Start the Telemetry supervisor
      CryptoVillainWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: CryptoVillain.PubSub},
      # Start the Endpoint (http/https)
      CryptoVillainWeb.Endpoint,
      # Start a worker of coins manager
      CryptoVillain.CoinsManager,
      # Start coins client processes registry
      {Registry, name: CryptoVillain.CoinsClientRegistry, keys: :unique},
      # DynamicSupervisor for client to getting crypto values
      {DynamicSupervisor, [name: CryptoVillain.Supervisor.CoinsClient, strategy: :one_for_one]},
      # Start Oban instance
      {Oban, Application.fetch_env!(:crypto_villain, Oban)}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CryptoVillain.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CryptoVillainWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
