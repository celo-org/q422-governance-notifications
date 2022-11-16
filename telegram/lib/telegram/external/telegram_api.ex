defmodule TelegramService.TelegramAPI do
  @moduledoc "Wrap telegram api operations"

  alias Telegram.Api, as: API
  alias TelegramService.Telemetry
  require Logger

  def identify(key), do: API.request(key, "getMe") |> handle_result(:identify)

  def remove_bot_commands(key), do: API.request(key, "deleteMyCommands") |> handle_result(:delete_commands)

  def set_bot_commands(key, commands), do: API.request(key, "setMyCommands", commands) |> handle_result(:set_commands)

  def send(chat_id, message) do
    "TELEGRAM_BOT_SECRET"
    |> System.get_env()
    |> send_message(chat_id, message)
    |> handle_result(:send)
  end

  defp send_message(key, chat_id, message) do
    Telemetry.count(:sent_msg)

    Telegram.Api.request(key, "sendMessage",
      chat_id: chat_id,
      parse_mode: "markdown",
      disable_web_page_preview: true,
      text: message
    )
  end

  def poll_messages(key, since) do
    Telegram.Api.request(key, "getUpdates", offset: since + 1, timeout: 30) |> handle_result(:poll)
  end

  defp handle_result(response, operation) do
    case response do
      {:ok, _} -> response
      {:error, reason} ->
        Logger.error("Telegram api error, operation=#{operation} error=#{reason |> inspect()}")
        response
    end
  end
end
