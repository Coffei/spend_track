defmodule SpendTrackWeb.AnalyticsController do
  use SpendTrackWeb, :controller

  alias SpendTrack.Payments

  def index(conn, params) do
    user_id = conn.assigns.current_user.id
    today = Date.utc_today()
    # Default to previous month if no params provided
    default_date = Timex.shift(today, months: -1)

    year = Map.get(params, "year", to_string(default_date.year)) |> String.to_integer()
    month = Map.get(params, "month", to_string(default_date.month)) |> String.to_integer()

    current_date = Date.new!(year, month, 1)
    from = Timex.beginning_of_month(current_date) |> Timex.to_datetime()
    to = Timex.end_of_month(current_date) |> Timex.to_datetime()

    {received, spent} = Payments.sum(user_id, from, to)
    category_sums = Payments.sum_by_category(user_id, from, to)

    render(conn, "index.html",
      current_date: current_date,
      received: received,
      spent: spent,
      category_sums: category_sums
    )
  end
end
