import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :crypto_villain, CryptoVillain.Repo, pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :crypto_villain, CryptoVillainWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 4002],
  secret_key_base: "6IujOcUTE43E+j3cX/SmEeb/kUErwSx2DS8r9fHipAQyEGiiQ0zgCvXVK7RJaH2W",
  server: false

# In test we don't send emails.
config :crypto_villain, CryptoVillain.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :info

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# To prevent Oban from running jobs and plugins during test runs
config :crypto_villain, Oban, testing: :inline
