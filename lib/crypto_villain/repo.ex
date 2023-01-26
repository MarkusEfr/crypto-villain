defmodule CryptoVillain.Repo do
  use Ecto.Repo,
    otp_app: :crypto_villain,
    adapter: Ecto.Adapters.Postgres
end
