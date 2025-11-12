defmodule SpendTrack.Rules do
  @moduledoc """
  The Rules context.
  """

  import Ecto.Query, warn: false
  alias SpendTrack.Repo
  alias SpendTrack.Model.Rule

  @spec list_rules() :: [Rule.t()]
  def list_rules do
    from(r in Rule,
      preload: [:category],
      order_by: [asc: r.name]
    )
    |> Repo.all()
  end

  @spec get_rule!(integer()) :: Rule.t()
  def get_rule!(id), do: Repo.get!(Rule, id) |> Repo.preload(:category)

  @spec create_rule(map()) :: {:ok, Rule.t()} | {:error, Ecto.Changeset.t()}
  def create_rule(attrs \\ %{}) do
    %Rule{}
    |> Rule.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_rule(Rule.t(), map()) :: {:ok, Rule.t()} | {:error, Ecto.Changeset.t()}
  def update_rule(%Rule{} = rule, attrs) do
    rule
    |> Rule.changeset(attrs)
    |> Repo.update()
  end

  @spec delete_rule(Rule.t()) :: {:ok, Rule.t()} | {:error, Ecto.Changeset.t()}
  def delete_rule(%Rule{} = rule) do
    Repo.delete(rule)
  end

  @spec change_rule(Rule.t(), map()) :: Ecto.Changeset.t()
  def change_rule(%Rule{} = rule, attrs \\ %{}) do
    Rule.changeset(rule, attrs)
  end
end
