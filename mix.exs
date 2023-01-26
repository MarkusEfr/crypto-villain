defmodule CryptoVillain.MixProject do
  use Mix.Project

  def project do
    [
      app: :crypto_villain,
      version: "0.1.0",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {CryptoVillain.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bcrypt_elixir, "~> 3.0"},
      {:phoenix, "~> 1.6.12"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.6"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.18.2"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.7.0"},
      {:esbuild, "~> 0.4", runtime: Mix.env() == :dev},
      {:swoosh, "~> 1.3"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.18"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      {:dart_sass, "~> 0.5", runtime: Mix.env() == :dev},
      {:ex_machina, "~> 2.7.0", only: :test},
      {:bootstrap_icons, "~> 0.4.0"},
      {:bodyguard, "~> 2.4.2"},
      {:guardian, "~> 2.0"},
      {:faker, "~> 0.17", only: :test},
      {:vex, "~> 0.9.0"},
      {:useful, "~> 1.0.8"},
      {:websockex, "~> 0.4.3"},
      {:dotenvy, "~> 0.7.0"},
      {:oban, "~> 2.13"},
      {:atomic_map, "~> 0.8"},
      {:decimal, "~> 2.0"},
      {:flop, "~> 0.18.4"},
      {:waffle,  "~> 1.1.6"},
      {:waffle_ecto, "~> 0.0.11"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.deploy": ["esbuild default --minify", "sass default --no-source-map --style=compressed", "phx.digest"]
    ]
  end

  # For compatibility with releases, configure your builds to copy (i.e. "overlay") the contents of your envs/ directory into the root of the release.
  defp releases do
    [
      crypto_villain: [
        include_executables_for: [:unix],
        steps: [:assemble, :tar],
        overlays: ["envs/", "priv/", "config/"]
        ]
    ]
    end
end
