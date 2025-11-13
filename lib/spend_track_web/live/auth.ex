defmodule SpendTrackWeb.Live.Auth do
  use SpendTrackWeb, :verified_routes
  alias SpendTrack.Users
  import Phoenix.Component, only: [assign_new: 3]
  import Phoenix.LiveView, only: [redirect: 2]

  def on_mount(:fetch_current_user, _params, session, socket) do
    user =
      case session["user_id"] do
        nil -> nil
        user_id -> Users.get_user!(user_id)
      end

    socket = assign_new(socket, :current_user, fn -> user end)

    {:cont, socket}
  end

  def on_mount(:require_user, _params, _session, socket) do
    if socket.assigns.current_user do
      {:cont, socket}
    else
      socket = redirect(socket, to: ~p"/")
      {:halt, socket}
    end
  end
end
