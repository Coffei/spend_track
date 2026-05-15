defmodule SpendTrackWeb.AnalyticsController do
  use SpendTrackWeb, :controller

  alias SpendTrack.Analytics

  @allowed_months [1, 3, 6, 12]

  def index(conn, params) do
    user_id = conn.assigns.current_user.id
    today = Date.utc_today()
    # Default to previous month if no params provided
    default_date = Timex.shift(today, months: -1)

    year = Map.get(params, "year", to_string(default_date.year)) |> String.to_integer()
    month = Map.get(params, "month", to_string(default_date.month)) |> String.to_integer()
    months = parse_months(Map.get(params, "months"))

    analytics = Analytics.get_period_analytics(user_id, year, month, months)

    render(conn, "index.html",
      current_date: analytics.current_date,
      start_date: analytics.start_date,
      months: analytics.months,
      received: analytics.received,
      spent: analytics.spent,
      category_sums: analytics.category_sums
    )
  end

  defp parse_months(nil), do: 1

  defp parse_months(value) when is_binary(value) do
    with {n, ""} <- Integer.parse(value),
         true <- n in @allowed_months do
      n
    else
      _ -> 1
    end
  end

  defp parse_months(_), do: 1
end
