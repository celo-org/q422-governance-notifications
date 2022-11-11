defmodule TelegramService.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  alias TelegramService.{Bot, SubscriptionQueue}

  @impl true
  def start(_type, _args) do
    Logger.info("Starting app")

    setup_metrics()

    bot_refresh_period =
      "BOT_POLL_TIME_SECONDS"
      |> System.get_env("5")
      |> String.to_integer()
      |> :timer.seconds()

    children = [
      # Telegram bot
      {Bot, bot_key: System.get_env("TELEGRAM_BOT_SECRET"), refresh: bot_refresh_period},
      {Task.Supervisor, name: TelegramService.IncomingMessageTasks},
      {Task.Supervisor, name: TelegramService.EventResponseTasks},

      # web
      {Phoenix.PubSub, name: Telegram.PubSub},
      TelegramWeb.Endpoint,

      # Subscriber cache
      {ConCache, [name: :subscriptions, ttl_check_interval: false]}
    ]

    opts = [strategy: :one_for_one, name: TelegramService.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp setup_metrics() do
    TelegramService.MetricsExporter.setup()
    TelegramService.Telemetry.Instrumentation.setup()
  end
end
