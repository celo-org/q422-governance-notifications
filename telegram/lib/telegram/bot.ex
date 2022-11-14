defmodule TelegramService.Bot do
  use GenServer
  require Logger

  alias TelegramService.MessageHandler, as: Handler
  alias TelegramService.TelegramAPI, as: Telegram

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, opts)
  end

  @impl GenServer
  def init(opts) do
    Logger.info("Telegram bot startup")

    {key, _opts} = Keyword.pop!(opts, :bot_key)
    {refresh_period, _opts} = Keyword.pop!(opts, :refresh)

    case Telegram.identify(key) do
      {:ok, me} ->
        Logger.info("Bot successfully self-identified: #{me["username"]}")

        state = %{
          bot_key: key,
          me: me,
          last_seen: -2,
          refresh_period: refresh_period,
          poll_timer: Process.send_after(self(), :poll, refresh_period)
        }

        {:ok, state, {:continue, :setup_commands}}

      error ->
        Logger.error("Bot failed to self-identify: #{inspect(error)}")
        :error
    end
  end

  @impl GenServer
  def handle_continue(:setup_commands, state = %{bot_key: key}) do
    commands = %{
      commands: [
        %{
          command: "subscribe",
          description: "Get cUSD transfer messages"
        },
        %{
          command: "governance",
          description: "Get governance proposal messages"
        },
        %{command: "unsubscribe", description: "Stop notifications"}
      ]
    }

    {:ok, _} = Telegram.remove_bot_commands(key)
    {:ok, _} = Telegram.set_bot_commands(key, commands)

    {:noreply, state}
  end

  @impl GenServer
  def handle_info(
        :poll,
        %{bot_key: key, last_seen: last_seen, poll_timer: timer, refresh_period: refresh_period} =
          state
      ) do
    Process.cancel_timer(timer)

    most_recent_message_id =
      case Telegram.poll_messages(key, last_seen) do
        {:ok, []} ->
          last_seen

        {:ok, messages} ->
          messages |> process_messages()
      end

    new_timer = Process.send_after(self(), :poll, refresh_period)

    {:noreply, %{state | poll_timer: new_timer, last_seen: most_recent_message_id}}
  end

  defp process_messages(messages) do
    messages |> Handler.handle_messages()

    messages
    |> Enum.map(fn message ->
      message["update_id"]
    end)
    |> Enum.max()
  end
end
