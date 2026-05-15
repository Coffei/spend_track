defmodule SpendTrackWeb.AnalyticsHTML do
  use SpendTrackWeb, :html

  embed_templates "analytics_html/*"

  @doc """
  Per-month average of `value` over an `n`-month window.

  Keeps figures comparable across window sizes — totals scale with the
  window, averages don't.
  """
  def per_month(value, 1), do: value

  def per_month(value, n) when is_integer(n) and n > 1 do
    Decimal.div(value, Decimal.new(n))
  end

  @doc """
  Scales the `total`, `spent`, and `received` of each category to a
  per-month average.
  """
  def chart_categories(category_sums, 1), do: category_sums

  def chart_categories(category_sums, months) when months > 1 do
    Enum.map(category_sums, fn cat ->
      %{
        cat
        | total: per_month(cat.total, months),
          spent: per_month(cat.spent, months),
          received: per_month(cat.received, months)
      }
    end)
  end

  @doc """
  Returns the header label for the analytics window.

  - Single-month window: "May 2026".
  - Multi-month window with both ends in same year: "Mar – May 2026 (3-month avg)".
  - Multi-month window spanning years: "Jun 2025 – May 2026 (12-month avg)".
  """
  def window_label(current_date, _start_date, 1) do
    Calendar.strftime(current_date, "%B %Y")
  end

  def window_label(current_date, start_date, months) do
    start_label =
      if start_date.year == current_date.year do
        Calendar.strftime(start_date, "%b")
      else
        Calendar.strftime(start_date, "%b %Y")
      end

    end_label = Calendar.strftime(current_date, "%b %Y")
    "#{start_label} – #{end_label} (#{months}-month avg)"
  end
end
