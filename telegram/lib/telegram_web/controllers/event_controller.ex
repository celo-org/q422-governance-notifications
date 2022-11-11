defmodule TelegramWeb.EventController do
  use TelegramWeb, :controller

  alias TelegramService.Events.EventHandler

  action_fallback TelegramWeb.FallbackController

  def receive(conn, event) do
    TelegramService.Telemetry.count(:received_event)

    {:response, code} = EventHandler.handle_event(event)

    conn
    |> put_status(code)
    |> render("received.json")
  end
end
