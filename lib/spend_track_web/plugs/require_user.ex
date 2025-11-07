defmodule SpendTrackWeb.Plugs.RequireUser do
  use SpendTrackWeb, :verified_routes
  import Plug.Conn
  import Phoenix.Controller
  alias SpendTrack.Model.User

  def init(opts), do: opts

  def call(conn, _opts) do
    case conn.assigns[:current_user] do
      nil ->
        conn
        |> put_flash(:error, "You must sign in to access this page")
        |> redirect(to: ~p"/")
        |> halt()

      %User{} ->
        conn
    end
  end
end
