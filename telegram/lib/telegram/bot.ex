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
          check_timer: Process.send_after(self(), :check, refresh_period)
        }

        {:ok, state, {:continue, :setup_commands}}

      error ->
        Logger.error("Bot failed to self-identify: #{inspect(error)}")
        :error
    end
  end

  def handle_continue(:setup_commands, state = %{bot_key: key}) do
    commands = %{
      commands: [
        %{
          command: "subscribe",
          description: "Subscribe to Celo mainnet governance proposal status changes"
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
        :check,
        %{bot_key: key, last_seen: last_seen, check_timer: timer, refresh_period: refresh_period} =
          state
      ) do
    Process.cancel_timer(timer)

    last_update =
      case Telegram.Api.request(key, "getUpdates", offset: last_seen + 1, timeout: 30) do
        {:ok, []} ->
          # no messages
          last_seen

        {:ok, messages} ->
          # process messages and find the max update_id for next poll
          messages
          |> Enum.map(fn message ->
            {:ok, _} = Handler.handle_message(message)

            message["update_id"]
          end)
          |> Enum.max()
      end

    new_timer = Process.send_after(self(), :check, refresh_period)

    {:noreply, %{state | check_timer: new_timer, last_seen: last_update}}
  end
end
