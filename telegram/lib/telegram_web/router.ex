defmodule TelegramWeb.Router do
  use TelegramWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", TelegramWeb do
    pipe_through :api
    post "/receive", EventController, :receive
  end
end
