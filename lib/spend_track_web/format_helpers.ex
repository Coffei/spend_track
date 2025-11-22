defmodule SpendTrackWeb.FormatHelpers do
  @moduledoc """
  Provides formatting helpers for the web interface.
  """

  @doc """
  Formats a currency amount.

  ## Examples

      iex> format_currency(1000)
      "1 000,00"

      iex> format_currency(1234.56)
      "1 234,56"

      iex> format_currency(Decimal.new("1234.56"))
      "1 234,56"

      iex> format_currency(nil)
      "0,00"
  """
  def format_currency(nil), do: "0,00"

  def format_currency(amount) do
    case Decimal.cast(amount) do
      {:ok, decimal} ->
        decimal
        |> Decimal.round(2)
        |> Number.Currency.number_to_currency(
          unit: "",
          separator: ",",
          delimiter: " ",
          precision: 2
        )
        |> String.trim()

      :error ->
        "0,00"
    end
  end
end
