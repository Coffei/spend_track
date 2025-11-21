defmodule SpendTrackWeb.AnalyticsHTML do
  use SpendTrackWeb, :html

  embed_templates "analytics_html/*"

  def format_currency(amount) do
    amount
    |> Decimal.round(2)
    |> Decimal.to_string()
    |> then(&"#{&1}")
  end
end
