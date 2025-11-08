defmodule SpendTrack.Model.Category do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer() | nil,
          name: String.t() | nil,
          color: String.t() | nil,
          payment_count: integer() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "categories" do
    field :name, :string
    field :color, :string
    field :payment_count, :integer, virtual: true

    has_many :payments, SpendTrack.Model.Payment

    timestamps()
  end

  @doc false
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :color])
    |> validate_required([:name, :color])
  end
end
