defmodule TelegramService.MessageHandler do
  require Logger

  alias TelegramService.TelegramAPI, as: Telegram
  alias TelegramService.Events.Subscriptions, as: Subscriptions
  alias TelegramService.Telemetry

  def handle_messages(messages) do
    messages
    |> Enum.each(fn msg ->
      Task.Supervisor.start_child(TelegramService.IncomingMessageTasks, fn ->
        Telemetry.count(:received_msg)

        handle_message(msg)
      end)
    end)
  end

  @doc """
  Destructure the telegram chat message. Expects output formatted from telegram api. e.g.

  %{
  "message" => %{
    "chat" => %{
      "first_name" => "dönild",
      "id" => 565192189,
      "type" => "private",
      "username" => "coolusername"
    },
    "date" => 1668005454,
    "from" => %{
      "first_name" => "dönild",
      "id" => 565192189,
      "is_bot" => false,
      "language_code" => "en",
      "username" => "coolusername"
    },
    "message_id" => 8,
    "text" => "hello i am the content of the message thanks goodnight"
  },
  "update_id" => 464939260
  }

  """
  def handle_message(%{
        "message" => %{"chat" => %{"id" => chat_id}, "from" => from, "text" => body}
      }) do
    Logger.info("Received message from: #{from["username"]} - #{body}")

    respond(body, chat_id)
  end

  def handle_message(_), do: {:error, :bad_format}

  defp respond("/subscribe" <> _rest, chat_id) do
    Telegram.send(chat_id, "you're subscribed!")
    Subscriptions.subscribe(chat_id)

    {:ok, :subscribe}
  end

  defp respond("/unsubscribe" <> _rest, chat_id) do
    Telegram.send(chat_id, "you're not subscribed anymore!!")
    Subscriptions.unsubscribe(chat_id)
    {:ok, :unsubscribe}
  end

  defp respond("/echo " <> msg, chat_id) do
    Telegram.send(chat_id, msg)
    {:ok, :echo}
  end

  defp respond("/start" <> _rest, chat_id) do
    Telegram.send(
      chat_id,
      "Hey! 👋 send /subscribe to get notifications on Celo mainnet governance proposals!"
    )

    {:ok, :start}
  end

  defp respond("sup" <> _rest, chat_id) do
    Telegram.send(chat_id, "ay yo what's good")
    {:ok, :random}
  end

  defp respond(_, _), do: {:ok, nil}
end
