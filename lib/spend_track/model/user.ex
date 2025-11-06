defmodule SpendTrack.Model.User do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer() | nil,
          name: String.t() | nil,
          email: String.t(),
          avatar_url: String.t() | nil,
          provider: String.t(),
          uid: String.t(),
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "users" do
    field :name, :string
    field :email, :string
    field :avatar_url, :string
    field :provider, :string
    field :uid, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :avatar_url, :provider, :uid])
    |> validate_required([:email, :provider, :uid])
    |> validate_format(:email, ~r/^\S+@\S+$/)
    |> unique_constraint(:email)
    |> unique_constraint([:provider, :uid], name: :users_provider_uid_index)
  end
end
