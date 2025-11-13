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

  @spec find_matching_payments(Rule.t(), integer()) :: [Payment.t()]
  def find_matching_payments(rule, limit \\ 20) do
    query = from(p in Payment)

    query =
      if rule.counterparty_filter not in [nil, ""] do
        from(p in query, where: like(p.counterparty, ^"%#{rule.counterparty_filter}%"))
      else
        query
      end

    query =
      if rule.note_filter not in [nil, ""] do
        from(p in query, where: like(p.note, ^"%#{rule.note_filter}%"))
      else
        query
      end

    from(p in query,
      limit: ^limit,
      order_by: [desc: p.time, asc: p.counterparty, asc: p.amount],
      preload: [:account]
    )
    |> Repo.all()
  end
end
