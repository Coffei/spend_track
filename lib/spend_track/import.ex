NimbleCSV.define(SpendTrack.CsvParser, separator: ";", escape: "\"")

defmodule SpendTrack.Import do
  alias SpendTrack.CsvParser

  @spec csv_to_payments(String.t()) :: {:ok, list(map())} | {:error, String.t()}
  def csv_to_payments(csv_string) do
    csv_string
    |> ensure_utf8()
    |> CsvParser.parse_string(skip_headers: false)
    |> convert()
  end

  defp ensure_utf8(string) do
    if String.valid?(string) do
      string
    else
      Codepagex.to_string!(string, "VENDORS/MICSFT/WINDOWS/CP1250")
    end
  end

  defp convert(csv_data) do
    # for now just detect KB and RB formats
    first_row = hd(csv_data)

    format = find_format(first_row)

    if format do
      {:ok, transform(csv_data, format)}
    else
      {:error, "Unknown format"}
    end
  end

  defp to_payments(data, time_key, amount_key, counterparty_key, note_keys) do
    Enum.map(data, fn row ->
      %{
        time: date(row[time_key]),
        amount: to_decimal(row[amount_key]),
        counterparty: row[counterparty_key],
        note:
          Enum.map(note_keys, fn key -> String.trim(row[key]) end)
          |> Enum.reject(&(&1 == ""))
          |> Enum.join(" / ")
          |> String.trim()
      }
    end)
  end

  defp to_map([headers | csv_data]) do
    Enum.map(csv_data, fn row ->
      headers
      |> Enum.zip(row)
      |> Enum.map(fn {header, value} -> {header, value} end)
      |> Map.new()
    end)
  end

  @formats ["{0D}.{0M}.{YYYY}", "{0D}.{0M}.{YYYY} {h24}:{m}"]
  defp date(string) do
    Enum.find_value(@formats, fn format ->
      case Timex.parse(string, format) do
        {:ok, datetime} -> Timex.to_datetime(datetime, "Etc/UTC")
        {:error, _} -> nil
      end
    end)
  end

  defp to_decimal(string) do
    string
    |> String.replace(",", ".")
    |> String.replace(" ", "")
    |> Decimal.new()
  end

  defp find_format([]) do
    nil
  end

  defp find_format([first_cell | _] = first_row) do
    cond do
      is_kb(first_cell) -> :kb
      is_rb(first_row) -> :rb
      true -> nil
    end
  end

  defp is_kb(first_cell) do
    first_cell == "KB+, vypis v csv. formatu"
  end

  defp is_rb(first_row) do
    Enum.all?(
      [
        "Datum zaúčtování",
        "Zaúčtovaná částka",
        "Měna účtu",
        "Číslo protiúčtu",
        "Název obchodníka",
        "Název protiúčtu",
        "Zpráva"
      ],
      &(&1 in first_row)
    )
  end

  defp transform(csv_data, :kb) do
    csv_data
    |> Enum.drop_while(fn [cell | _] -> cell != "Datum zauctovani" end)
    |> to_map()
    |> to_payments("Datum zauctovani", "Castka", "Protistrana", [
      "Nazev protiuctu",
      "Popis pro me",
      "Zprava pro prijemce"
    ])
  end

  defp transform(csv_data, :rb) do
    csv_data
    |> to_map()
    |> to_payments("Datum zaúčtování", "Zaúčtovaná částka", "Číslo protiúčtu", [
      "Název obchodníka",
      "Název protiúčtu",
      "Zpráva"
    ])
  end
end
