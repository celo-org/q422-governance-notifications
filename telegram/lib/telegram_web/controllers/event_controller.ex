defmodule TelegramWeb.EventController do
  use TelegramWeb, :controller

  action_fallback TelegramWeb.FallbackController

  def receive(conn, _params) do
    TelegramService.Telemetry.count(:received_event)

    conn
    |> put_status(200)
    |> render("received.json")
  end
end
