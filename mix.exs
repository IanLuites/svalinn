defmodule Svalinn.MixProject do
  use Mix.Project

  def project do
    [
      app: :svalinn,
      description: "Secure token generation and decoding.",
      version: "0.0.1",
      elixir: "~> 1.6",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],

      # Docs
      name: "Svalinn",
      source_url: "https://github.com/IanLuites/svalinn",
      homepage_url: "https://github.com/IanLuites/svalinn",
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  def package do
    [
      name: :svalinn,
      maintainers: ["Ian Luites"],
      licenses: ["MIT"],
      files: [
        # Elixir
        "lib/svalinn",
        "lib/svalinn.ex",
        "mix.exs",
        "README*",
        "LICENSE*"
      ],
      links: %{
        "GitHub" => "https://github.com/IanLuites/svalinn"
      }
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:msgpax, "~> 2.0"},
      {:analyze, "~> 0.1", only: [:dev, :test], runtime: false}
    ]
  end
end
