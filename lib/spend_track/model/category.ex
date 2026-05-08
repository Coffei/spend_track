defmodule SpendTrack.Model.Category do
  use Ecto.Schema
  import Ecto.Changeset

  alias SpendTrack.Model.User

  @type t :: %__MODULE__{
          id: integer() | nil,
          name: String.t() | nil,
          color: String.t() | nil,
          user_id: integer() | nil,
          payment_count: integer() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "categories" do
    field :name, :string
    field :color, :string
    field :hide_in_analytics, :boolean, default: false
    field :payment_count, :integer, virtual: true

    belongs_to :user, User
    has_many :payments, SpendTrack.Model.Payment

    timestamps()
  end

  @doc false
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :color, :user_id, :hide_in_analytics])
    |> validate_required([:name, :color, :user_id])
  end
end
