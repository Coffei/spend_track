defmodule SpendTrack.Model.Rule do
  use Ecto.Schema
  import Ecto.Changeset

  alias SpendTrack.Model.Category

  @type t :: %__MODULE__{
          id: integer() | nil,
          name: String.t() | nil,
          category_id: integer() | nil,
          counterparty_filter: String.t() | nil,
          note_filter: String.t() | nil,
          category: Category.t() | Ecto.Association.NotLoaded.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "rules" do
    field :name, :string
    field :counterparty_filter, :string
    field :note_filter, :string

    belongs_to :category, Category

    timestamps()
  end

  @doc false
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(rule, attrs) do
    rule
    |> cast(attrs, [:name, :category_id, :counterparty_filter, :note_filter])
    |> normalize_empty_strings()
    |> validate_required([:name, :category_id])
    |> validate_at_least_one_filter()
  end

  defp normalize_empty_strings(changeset) do
    changeset
    |> update_change(:counterparty_filter, fn
      "" -> nil
      val when is_binary(val) -> String.trim(val) |> then(&if &1 == "", do: nil, else: &1)
      val -> val
    end)
    |> update_change(:note_filter, fn
      "" -> nil
      val when is_binary(val) -> String.trim(val) |> then(&if &1 == "", do: nil, else: &1)
      val -> val
    end)
  end

  defp validate_at_least_one_filter(changeset) do
    counterparty = get_field(changeset, :counterparty_filter)
    note = get_field(changeset, :note_filter)

    if (is_nil(counterparty) or counterparty == "") and (is_nil(note) or note == "") do
      add_error(changeset, :base, "At least one filter (counterparty or note) must be filled")
    else
      changeset
    end
  end
end
