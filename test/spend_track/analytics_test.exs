defmodule SpendTrack.AnalyticsTest do
  use SpendTrack.DataCase, async: true

  alias SpendTrack.Analytics
  alias SpendTrack.Model.Account
  alias SpendTrack.Model.Category
  alias SpendTrack.Model.Payment
  alias SpendTrack.Model.User

  defp create_user! do
    Repo.insert!(%User{
      email: "user-#{System.unique_integer([:positive])}@example.com",
      provider: "google",
      uid: "uid-#{System.unique_integer([:positive])}"
    })
  end

  defp create_account!(user) do
    Repo.insert!(%Account{name: "Main", color: "#000000", user_id: user.id})
  end

  defp create_category!(user, attrs) do
    Repo.insert!(%Category{
      name: attrs[:name],
      color: attrs[:color] || "#888888",
      hide_in_analytics: attrs[:hide_in_analytics] || false,
      user_id: user.id
    })
  end

  defp create_payment!(account, attrs) do
    {:ok, datetime, _} = DateTime.from_iso8601(attrs[:time])

    Repo.insert!(%Payment{
      time: datetime,
      amount: Decimal.new(attrs[:amount]),
      counterparty: attrs[:counterparty] || "test",
      account_id: account.id,
      category_id: attrs[:category_id]
    })
  end

  describe "get_period_analytics/4" do
    test "with months = 1 returns single-month totals matching the selected month" do
      user = create_user!()
      account = create_account!(user)
      food = create_category!(user, name: "Food", color: "#ff0000")

      create_payment!(account,
        time: "2026-05-10T12:00:00Z",
        amount: "-100",
        category_id: food.id
      )

      create_payment!(account,
        time: "2026-05-20T12:00:00Z",
        amount: "200",
        category_id: food.id
      )

      # Payment outside the window must not be included.
      create_payment!(account,
        time: "2026-04-15T12:00:00Z",
        amount: "-999",
        category_id: food.id
      )

      result = Analytics.get_period_analytics(user.id, 2026, 5, 1)

      assert result.current_date == ~D[2026-05-01]
      assert result.start_date == ~D[2026-05-01]
      assert result.months == 1
      assert Decimal.equal?(result.received, Decimal.new("200"))
      assert Decimal.equal?(result.spent, Decimal.new("-100"))
      assert [%{name: "Food", total: total}] = result.category_sums
      assert Decimal.equal?(total, Decimal.new("100"))
    end

    test "with months = 3 sums payments across the 3-month window inclusive" do
      user = create_user!()
      account = create_account!(user)
      food = create_category!(user, name: "Food", color: "#ff0000")

      # First month of window.
      create_payment!(account,
        time: "2026-03-05T12:00:00Z",
        amount: "-10",
        category_id: food.id
      )

      # Middle month.
      create_payment!(account,
        time: "2026-04-15T12:00:00Z",
        amount: "-20",
        category_id: food.id
      )

      # Last month (selected month).
      create_payment!(account,
        time: "2026-05-25T12:00:00Z",
        amount: "100",
        category_id: food.id
      )

      # Just before window — excluded.
      create_payment!(account,
        time: "2026-02-28T12:00:00Z",
        amount: "-500",
        category_id: food.id
      )

      result = Analytics.get_period_analytics(user.id, 2026, 5, 3)

      assert result.current_date == ~D[2026-05-01]
      assert result.start_date == ~D[2026-03-01]
      assert result.months == 3
      assert Decimal.equal?(result.received, Decimal.new("100"))
      assert Decimal.equal?(result.spent, Decimal.new("-30"))
      assert [%{name: "Food", total: total}] = result.category_sums
      assert Decimal.equal?(total, Decimal.new("70"))
    end

    test "returns zeroes and empty breakdown when there are no payments in window" do
      user = create_user!()
      _account = create_account!(user)

      result = Analytics.get_period_analytics(user.id, 2026, 5, 3)

      assert Decimal.equal?(result.received, Decimal.new(0))
      assert Decimal.equal?(result.spent, Decimal.new(0))
      assert result.category_sums == []
    end
  end
end
