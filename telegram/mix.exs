defmodule Telegram.MixProject do
  use Mix.Project

  def project do
    [
      app: :telegram,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :prometheus_ex]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:telegram, git: "https://github.com/visciang/telegram.git", tag: "0.22.2"},
      {:prometheus_ex, "~> 3.0"},
      {:elixir_talk, "~> 1.2"},
      {:observer_cli, "~> 1.6"},
      {:telemetry, "~> 1.0"}
    ]
  end
end
