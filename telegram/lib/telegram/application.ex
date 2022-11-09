defmodule TelegramService.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    Logger.info("start app")
    children = [
      {TelegramService.Bot, bot_key: System.get_env("TELEGRAM_BOT_SECRET")}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TelegramService.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
