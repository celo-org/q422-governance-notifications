defmodule TelegramService.Telemetry.Instrumentation do
  use Prometheus.Metric

  @counters [
    %{metric_name: "received_events", help: "Number of events received on the api endpoint", telemetry_id: :received_event },
    %{metric_name: "received_telegram_messages", help: "Number of messages received via telegram", telemetry_id: :received_msg },
    %{metric_name: "sent_telegram_messages", help: "Number of messages sent via telegram", telemetry_id: :sent_msg },
    %{metric_name: "subscriptions", help: "Number of subscriptions", telemetry_id: :subscribe },
    %{metric_name: "unsubscribe", help: "Number of unsubscriptions", telemetry_id: :unsubscribe },
  ]

  def setup() do
    @counters
    |> Enum.each( fn %{metric_name: name, help: help, telemetry_id: id} ->
      Counter.declare(
        name: name,
        help: help
      )

      :telemetry.attach(handler_id(name), [:telegram, id], &__MODULE__.handle_counter/4, %{metric_name: name})
    end)
  end

  def handler_id(name), do: "handler-#{name}"

  def handle_counter(_event_name, %{count: count}, _event_metadata, %{metric_name: name}) do
    Counter.inc([name: name], count)
  end
end