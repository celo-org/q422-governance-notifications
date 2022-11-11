defmodule TelegramService.Events.EventHandler do
  @moduledoc "Respond to incoming blockchain events"

  alias TelegramService.Events.Subscriptions
  alias TelegramService.Events.MessageFormatter, as: Formatter
  alias TelegramService.TelegramAPI, as: Telegram
  alias TelegramService.Telemetry

  require Logger

  def handle_event(%{"contract_address_hash" => _contract, "topic" => _topic} = event) do
    Task.Supervisor.start_child(TelegramService.EventResponseTasks, fn ->
      process_event(event)
    end)

    {:response, 200}
  end

  def handle_event(invalid_event) do
    Logger.error("Received invalid event - #{inspect(invalid_event)}}")
    {:reponse, 422}
  end

  def process_event(event) do
    case Subscriptions.get_subscribers(event) do
      [] -> :ok

      subscribers when is_list(subscribers) ->
        message = Formatter.format(event)

        subscribers
        |> Enum.each( fn subscriber ->
          Task.Supervisor.start_child(TelegramService.EventResponseTasks, fn ->
            Telemetry.count(:chain_event_notification_sent)

            Telegram.send(subscriber, message)
          end)
        end)
    end
  end
end