defmodule TelegramService.MixProject do
  use Mix.Project

  def project do
    [
      app: :telegram_service,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :prometheus_ex, :connection, :prometheus_plugs],
      mod: {TelegramService.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:telegram, git: "https://github.com/visciang/telegram.git", tag: "0.22.2"},
      {:prometheus_ex, "~> 3.0"},
      {:elixir_talk, "~> 1.2"},
      {:observer_cli, "~> 1.6"},
      {:telemetry, "~> 1.0"},
      {:phoenix, "~> 1.6.2"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      {:prometheus_plugs, "~> 1.1"},
      {:prometheus_process_collector, "~> 1.1"}
    ]
  end
end
