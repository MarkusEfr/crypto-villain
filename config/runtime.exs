import Config
import Dotenvy

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/crypto_villain start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.

dir = System.get_env("RELEASE_ROOT") || "envs/"

source!([
  "#{dir}#{config_env()}.env",
  "#{dir}#{config_env()}.local.env",
  System.get_env()
])

config :crypto_villain, CryptoVillain.Repo,
  database: env!("DATABASE_NAME", :string!),
  username: env!("DATABASE_USER", :string),
  password: env!("DATABASE_PASS", :string),
  hostname: env!("DATABASE_HOST", :string!)

config :crypto_villain, CryptoVillainWeb.Endpoint,
  secret_key_base: env!("SECRET_KEY_BASE", :string)
