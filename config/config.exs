# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :crypto_villain,
  ecto_repos: [CryptoVillain.Repo]

# Configures the endpoint
config :crypto_villain, CryptoVillainWeb.Endpoint,
  url: [host: "0.0.0.0"],
  render_errors: [view: CryptoVillainWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: CryptoVillain.PubSub,
  live_view: [signing_salt: "9LzeLBqc"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :crypto_villain, CryptoVillain.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :dart_sass,
  version: "1.55.0",
  default: [
    args: ~w(css/app.scss ../priv/static/assets/app.css),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

config :crypto_villain, CryptoVillain.Guardian,
  secret_key: "gglWehXB9o81xaZNWfHYddOhNjnj0X1gZk3OfnGNznEkFSjZ9ofWlTJIF7kkdR+g",
  issuer: "crypto_villain",
  ttl: {7, :days}

config :crypto_villain, CryptoVillainWeb.ApiAuthPipeline,
  error_handler: CryptoVillainWeb.ApiAuthErrorHandler,
  module: CryptoVillain.Guardian

config :crypto_villain, Oban,
  repo: CryptoVillain.Repo,
  plugins: [{Oban.Plugins.Pruner, max_age: 300}],
  queues: [default: 10, events: 50]

config :flop, repo: CryptoVillain.Repo, default_limit: 15

config :waffle, storage: Waffle.Storage.Local
