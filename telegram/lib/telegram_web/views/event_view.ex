defmodule TelegramWeb.EventView do
  use TelegramWeb, :view
  alias TelegramWeb.EventView

  def render("show.json", _) do
    %{data: %{}}
  end
end
