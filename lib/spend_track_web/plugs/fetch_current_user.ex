defmodule SpendTrackWeb.Plugs.FetchCurrentUser do
  import Plug.Conn
  alias SpendTrack.Users

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_session(conn, :user_id) do
      nil -> assign(conn, :current_user, nil)
      user_id -> assign(conn, :current_user, Users.get_user!(user_id))
    end
  end
end
