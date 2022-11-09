defmodule TelegramService.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  alias TelegramService.{Bot, ReplyCoordinator, SubscriptionQueue}

  @impl true
  def start(_type, _args) do
    Logger.info("Starting app")

    bot_refresh_period = "BOT_POLL_TIME_SECONDS"
                         |> System.get_env("5")
                         |> String.to_integer()
                         |> :timer.seconds()
    children = [
      {Bot, bot_key: System.get_env("TELEGRAM_BOT_SECRET"), refresh: bot_refresh_period},
      {ReplyCoordinator, bot_key: System.get_env("TELEGRAM_BOT_SECRET"), name: ReplyCoordinator},
      {SubscriptionQueue,
        beanstalkd_host: System.get_env("BEANSTALKD_HOST"),
        beanstalkd_port: System.get_env("BEANSTALKD_PORT"),
        beanstalkd_tube: System.get_env("BEANSTALKD_TUBE"),
        name: SubscriptionQueue
      }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TelegramService.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
