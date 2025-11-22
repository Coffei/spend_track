defmodule SpendTrackWeb.FormatHelpersTest do
  use ExUnit.Case, async: true
  import SpendTrackWeb.FormatHelpers

  describe "format_currency/1" do
    test "formats integer" do
      assert format_currency(1000) == "1 000,00"
    end

    test "formats float" do
      assert format_currency(1234.56) == "1 234,56"
    end

    test "formats decimal" do
      assert format_currency(Decimal.new("1234.56")) == "1 234,56"
    end

    test "formats large number" do
      assert format_currency(1_000_000) == "1 000 000,00"
    end

    test "formats zero" do
      assert format_currency(0) == "0,00"
    end

    test "formats nil" do
      assert format_currency(nil) == "0,00"
    end

    test "rounds to 2 decimal places" do
      assert format_currency(1234.567) == "1 234,57"
      assert format_currency(1234.564) == "1 234,56"
    end
  end
end
