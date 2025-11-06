defmodule SpendTrackWeb.SessionController do
  use SpendTrackWeb, :controller

  def new(conn, _params) do
    render(conn, :new)
  end
end
