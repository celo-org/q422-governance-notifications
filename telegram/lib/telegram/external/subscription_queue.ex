defmodule TelegramService.SubscriptionQueue do
  use GenServer
  require Logger
  alias TelegramService.Telemetry

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenServer
  def init(opts) do
    {host, _opts} = Keyword.pop!(opts, :beanstalkd_host)
    host = host |> to_charlist()

    {port, _opts} = Keyword.pop!(opts, :beanstalkd_port)
    {tube, _opts} = Keyword.pop!(opts, :beanstalkd_tube)

    {:ok, pid} = ElixirTalk.connect(host, port |> String.to_integer())
    {:using, ^tube} = ElixirTalk.use(pid, tube)

    state = %{
      queue: pid
    }

    {:ok, state}
  end

  @impl GenServer
  def handle_cast({:subscribe, chat_id, options}, %{queue: queue} = state) do
    Logger.info("Subscribing #{chat_id}")
    Telemetry.count(:subscribe)
    message = format_message(:subscribe, chat_id, options)

    queue |> ElixirTalk.put(message)

    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:unsubscribe, chat_id, options}, %{queue: queue} = state) do
    Logger.info("Unsubscribing #{chat_id}")
    Telemetry.count(:unsubscribe)

    message = format_message(:subscribe, chat_id, options)

    queue |> ElixirTalk.put(message)

    {:noreply, state}
  end

  def subscribe(chat_id, options \\ %{}) do
    GenServer.cast(__MODULE__, {:subscribe, chat_id, options})
  end

  def unsubscribe(chat_id, options \\ %{}) do
    GenServer.cast(__MODULE__, {:unsubscribe, chat_id, options})
  end

  defp format_message(action, chat_id, meta \\ %{}) do
    %{
      subscriber: chat_id,
      platform: "telegram",
      platform_meta: meta,
      action: action,
      # governance proxy
      contract_address_hash: "0xd533ca259b330c7a88f74e000a3faea2d63b7972",
      # proposal queued
      event_topic: "0x1bfe527f3548d9258c2512b6689f0acfccdd0557d80a53845db25fc57e93d8fe"
    }
    |> Jason.encode!()
  end
end
