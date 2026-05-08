defmodule SpendTrack.Model.Payment do
  use Ecto.Schema
  import Ecto.Changeset

  alias SpendTrack.Model.Account
  alias SpendTrack.Model.Category
  alias SpendTrack.Model.Rule

  @type t :: %__MODULE__{
          id: integer() | nil,
          time: DateTime.t() | nil,
          amount: Decimal.t() | nil,
          note: String.t() | nil,
          counterparty: String.t() | nil,
          account_id: integer() | nil,
          category_id: integer() | nil,
          rule_id: integer() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "payments" do
    field :time, :utc_datetime
    field :amount, :decimal
    field :note, :string
    field :counterparty, :string

    belongs_to :account, Account
    belongs_to :category, Category
    belongs_to :rule, Rule

    timestamps()
  end

  @doc false
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(payment, attrs) do
    payment
    |> cast(attrs, [:time, :amount, :note, :counterparty, :account_id, :category_id, :rule_id])
    |> validate_required([:time, :amount, :counterparty, :account_id])
  end
end
