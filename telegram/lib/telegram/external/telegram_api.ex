defmodule TelegramService.TelegramAPI do
  alias Telegram.Api, as: API
  alias TelegramService.Telemetry

  def identify(key), do: API.request(key, "getMe")

  def remove_bot_commands(key), do: API.request(key, "deleteMyCommands")

  def set_bot_commands(key, commands), do: API.request(key, "setMyCommands", commands)

  def send(chat_id, message) do
    "TELEGRAM_BOT_SECRET"
    |> System.get_env()
    |> send_message(chat_id, message)
  end

  def send_message(key, chat_id, message) do
    Telemetry.count(:sent_msg)

    Telegram.Api.request(key, "sendMessage",
      chat_id: chat_id,
      parse_mode: "markdown",
      disable_web_page_preview: true,
      text: message
    )
  end

  def poll_messages(key, since) do
    Telegram.Api.request(key, "getUpdates", offset: since + 1, timeout: 30)
  end
end
