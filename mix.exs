defmodule Zukini.MixProject do
  use Mix.Project

  def project do
    [
      app: :zukini,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Zukini.Application, []},
      extra_applications: [:logger, :ranch]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nimble_publisher, "~> 0.1.3"},
      {:phoenix_live_view, "~> 0.18.2"},
      {:plug_cowboy, "~> 2.0"},
      {:esbuild, "~> 0.5"},
      {:tailwind, "~> 0.1.8"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp aliases() do
    [
      "site.build": ["build", "tailwind default --minify", "esbuild default --minify"],
      devserver: ["phx.server"]
    ]
  end
end
