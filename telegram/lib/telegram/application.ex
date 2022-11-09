defmodule TelegramService.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    Logger.info("start app")

    bot_refresh_period = "BOT_POLL_TIME_SECONDS"
                         |> System.get_env("5")
                         |> String.to_integer()
                         |> :timer.seconds()
    children = [
      {TelegramService.Bot, bot_key: System.get_env("TELEGRAM_BOT_SECRET"), refresh: bot_refresh_period},
      {TelegramService.ReplyCoordinator, bot_key: System.get_env("TELEGRAM_BOT_SECRET"), name: TelegramService.ReplyCoordinator}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TelegramService.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
