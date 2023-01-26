{:ok, _} = Application.ensure_all_started(:ex_machina)
ExUnit.start()
Faker.start()
:ok = Ecto.Adapters.SQL.Sandbox.checkout(CryptoVillain.Repo)
