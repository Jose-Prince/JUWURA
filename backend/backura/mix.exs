defmodule Backura.MixProject do
  use Mix.Project

  def project do
    [
      app: :backura,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: [:cowboy, :logger, :plug, :jason ,:mongodb_driver], mod: {JAPI, []}, env: [cowboy_port: 8080]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:cowboy, "~> 1.1.2"},
      {:plug, "~> 1.3.4"},
      {:mongodb_driver, "~> 1.5.0"},
      {:poolboy, "~> 1.5.2"},
      {:decimal, "~> 2.1"} ,
      {:jason, "~> 1.4"}
    ]
  end
end
