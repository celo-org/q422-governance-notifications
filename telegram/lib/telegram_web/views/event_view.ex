defmodule TelegramWeb.EventView do
  use TelegramWeb, :view
  alias TelegramWeb.EventView

  def render("received.json", _) do
    %{status: 200}
  end
end
