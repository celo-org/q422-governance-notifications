defmodule TelegramService.MessageHandler do
  require Logger

  alias TelegramService.ReplyCoordinator, as: Reply
  alias TelegramService.SubscriptionQueue, as: Subscriptions

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
  def handle_message(%{"message" => %{"chat" => %{"id" => chat_id}, "from" => from, "text" => body}}) do
    Logger.info("Received message from: #{from["username"]} - #{body}")

    case get_response(body) do
      {:ok, :subscribe} = result ->
        Reply.send(chat_id, "you're subscribed!")
        Subscriptions.subscribe(chat_id)
        result

      {:ok, :unsubscribe} = result ->
        Reply.send(chat_id, "you're not subscribed anymore!!")
        Subscriptions.unsubscribe(chat_id)
        result

      {:ok, :random} = result ->
        Reply.send(chat_id, "ay yo what's good")
        result

      {:ok, :echo} = result ->
        "/echo " <> msg = body
        Reply.send(chat_id, msg)
        result

      {:ok, _} = result -> result
    end
  end

  def handle_message(_), do: {:error, :bad_format}

  def get_response("/subscribe" <> _rest), do: {:ok, :subscribe}
  def get_response("/unsubscribe" <> _rest), do: {:ok, :unsubscribe}
  def get_response("/echo " <> _rest), do: {:ok, :echo}
  def get_response("sup" <> _rest), do: {:ok, :random}
  def get_response(msg) do
    {:ok, nil}
  end
end