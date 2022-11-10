defmodule TelegramWeb.EventController do
  use TelegramWeb, :controller

  action_fallback TelegramWeb.FallbackController

  def receive(conn, _params) do
    conn
    |> put_status(:not_found)
    |> render("show.json")
  end
#
#  def create(conn, %{"user" => user_params}) do
#    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
#      conn
#      |> put_status(:created)
#      |> put_resp_header("location", Routes.user_path(conn, :show, user))
#      |> render("show.json", user: user)
#    end
#  end
end
