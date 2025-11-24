defmodule SpendTrackWeb.PageController do
  use SpendTrackWeb, :controller

  alias SpendTrack.Analytics

  def home(conn, _params) do
    if conn.assigns.current_user do
      analytics_data = Analytics.get_home_analytics(conn.assigns.current_user.id)
      render(conn, :home, analytics_data: analytics_data)
    else
      render(conn, :home)
    end
  end
end
