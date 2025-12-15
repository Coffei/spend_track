defmodule SpendTrack.Analytics do
  @moduledoc """
  Context for analytics data aggregation.
  """

  alias SpendTrack.Payments

  @doc """
  Returns analytics data for the home page (last 3 months).
  """
  def get_home_analytics(user_id) do
    today = Date.utc_today()
    # Get current month and previous 2 months
    months =
      0..2
      |> Enum.map(&Timex.shift(today, months: -&1))
      |> Enum.map(fn date -> {date.year, date.month} end)
      |> Enum.reverse()

    Enum.map(months, fn {year, month} ->
      get_month_analytics(user_id, year, month)
    end)
  end

  @spec get_month_analytics(pos_integer(), pos_integer(), pos_integer()) :: %{
          date: Date.t(),
          received: Decimal.t(),
          spent: Decimal.t(),
          received_diff: Decimal.t(),
          spent_diff: Decimal.t(),
          top_categories:
            list(%{
              name: String.t(),
              color: String.t(),
              total: Decimal.t()
            }),
          top_received_categories:
            list(%{
              name: String.t(),
              color: String.t(),
              total: Decimal.t()
            })
        }
  defp get_month_analytics(user_id, year, month) do
    current_date = Date.new!(year, month, 1)
    from = Timex.beginning_of_month(current_date) |> Timex.to_datetime()
    to = Timex.end_of_month(current_date) |> Timex.to_datetime()

    # Previous month for diff calculation
    prev_date = Timex.shift(current_date, months: -1)
    prev_from = Timex.beginning_of_month(prev_date) |> Timex.to_datetime()
    prev_to = Timex.end_of_month(prev_date) |> Timex.to_datetime()

    {received, spent} = Payments.sum(user_id, from, to)
    {prev_received, prev_spent} = Payments.sum(user_id, prev_from, prev_to)

    # Top 3 categories
    category_sums = Payments.sum_by_category(user_id, from, to)

    top_categories =
      category_sums
      |> Enum.filter(fn cat -> Decimal.lt?(cat.total, 0) end)
      # spent is negative, so smallest (most negative) is top spender
      |> Enum.sort_by(& &1.total, {:asc, Decimal})
      |> Enum.take(3)

    top_received_categories =
      category_sums
      |> Enum.filter(fn cat -> Decimal.gt?(cat.total, 0) end)
      |> Enum.sort_by(& &1.total, {:desc, Decimal})
      |> Enum.take(3)

    %{
      date: current_date,
      received: received,
      spent: spent,
      received_diff: Decimal.sub(received, prev_received),
      spent_diff: Decimal.sub(spent, prev_spent),
      top_categories: top_categories,
      top_received_categories: top_received_categories
    }
  end
end
