defmodule TelegramService.ReplyCoordinator do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenServer
  def init(opts) do
    {api_key, _opts} = Keyword.pop!(opts, :bot_key)

    state = %{
      key: api_key
    }

    {:ok, state}
  end

  @impl GenServer
  def handle_cast({:send, {chat_id, message}}, %{key: key} = state) do
    # todo: send via task
    Telegram.Api.request(key, "sendMessage",
      chat_id: chat_id,
      text: message
    )

    {:noreply, state}
  end

  def send(chat_id, message) do
    GenServer.cast(__MODULE__, {:send, {chat_id, message}})
  end
end
