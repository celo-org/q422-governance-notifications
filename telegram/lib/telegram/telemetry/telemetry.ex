defmodule TelegramService.Telemetry do
  def count(name, value \\1) do
    :telemetry.execute([:telegram, name], %{count: value})
  end
end