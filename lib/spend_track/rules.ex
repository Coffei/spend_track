defmodule SpendTrack.Rules do
  @moduledoc """
  The Rules context.
  """

  import Ecto.Query, warn: false
  alias SpendTrack.Repo
  alias SpendTrack.Model.Rule
  alias SpendTrack.Model.Payment

  @type match_stats :: %{applied: non_neg_integer(), unapplied: non_neg_integer()}

  @spec list_rules(integer()) :: [Rule.t()]
  def list_rules(user_id) do
    from(r in Rule,
      where: r.user_id == ^user_id,
      preload: [:category],
      order_by: [asc: r.name]
    )
    |> Repo.all()
  end

  @spec get_rule!(integer(), integer()) :: Rule.t()
  def get_rule!(id, user_id) do
    from(r in Rule, where: r.id == ^id and r.user_id == ^user_id)
    |> Repo.one!()
    |> Repo.preload(:category)
  end

  @spec create_rule(integer(), map()) ::
          {:ok, Rule.t(), match_stats()} | {:error, Ecto.Changeset.t()}
  def create_rule(user_id, attrs \\ %{}) do
    %Rule{}
    |> Rule.changeset(Map.put(attrs, "user_id", user_id))
    |> Repo.insert()
    |> then(fn
      {:ok, run} ->
        stats = run_all(run.user_id)
        {:ok, run, stats}

      error ->
        error
    end)
  end

  @spec update_rule(Rule.t(), map()) ::
          {:ok, Rule.t(), match_stats()} | {:error, Ecto.Changeset.t()}
  def update_rule(%Rule{} = rule, attrs) do
    rule
    |> Rule.changeset(attrs)
    |> Repo.update()
    |> then(fn
      {:ok, run} ->
        stats = run_all(run.user_id)
        {:ok, run, stats}

      error ->
        error
    end)
  end

  @spec delete_rule(Rule.t()) :: {:ok, Rule.t(), match_stats()} | {:error, Ecto.Changeset.t()}
  def delete_rule(%Rule{} = rule) do
    Repo.delete(rule)
    |> then(fn
      {:ok, run} ->
        # here we could rematch payments with the category of the deleted rule, but just re-match
        # all for now
        stats = run_all(run.user_id)
        {:ok, run, stats}

      error ->
        error
    end)
  end

  @spec change_rule(Rule.t(), map()) :: Ecto.Changeset.t()
  def change_rule(%Rule{} = rule, attrs \\ %{}) do
    Rule.changeset(rule, attrs)
  end

  @spec find_matching_payments(Rule.t(), integer(), integer()) :: [Payment.t()]
  def find_matching_payments(rule, user_id, limit \\ 20) do
    query =
      from(p in Payment,
        join: a in assoc(p, :account),
        where: a.user_id == ^user_id
      )

    query =
      if rule.counterparty_filter not in [nil, ""] do
        from([p, _a] in query, where: like(p.counterparty, ^"%#{rule.counterparty_filter}%"))
      else
        query
      end

    query =
      if rule.note_filter not in [nil, ""] do
        from([p, _a] in query, where: like(p.note, ^"%#{rule.note_filter}%"))
      else
        query
      end

    from([p, _a] in query,
      limit: ^limit,
      order_by: [desc: p.time, asc: p.counterparty, asc: p.amount],
      preload: [:account, :category]
    )
    |> Repo.all()
  end

  @spec find_category_for_payment(Payment.t(), integer()) :: integer() | nil
  def find_category_for_payment(payment, user_id) do
    from(r in Rule,
      where: r.user_id == ^user_id,
      where:
        (is_nil(r.counterparty_filter) or
           like(^payment.counterparty, fragment("'%' || ? || '%'", r.counterparty_filter))) and
          (is_nil(r.note_filter) or
             like(^payment.note, fragment("'%' || ? || '%'", r.note_filter))),
      order_by: [asc: r.id],
      limit: 1,
      select: r.category_id
    )
    |> Repo.one()
  end

  @spec run_all(integer()) :: match_stats
  def run_all(user_id) do
    sql = """
    WITH matching_rules AS (
      SELECT DISTINCT ON (p.id) p.id as pid, r.id as rid, r.category_id
      FROM payments p
      INNER JOIN accounts a ON a.id = p.account_id AND a.user_id = $1
      LEFT OUTER JOIN rules r
        ON r.user_id = $1
        AND (r.counterparty_filter IS NULL OR p.counterparty LIKE '%' || r.counterparty_filter || '%')
        AND (r.note_filter IS NULL OR p.note LIKE '%' || r.note_filter || '%')
      ORDER BY p.id, r.id
    ), stats_data AS (
      SELECT p.id, mr.category_id
      FROM payments p
      INNER JOIN matching_rules mr
        ON p.id = mr.pid
      WHERE p.category_id IS DISTINCT FROM mr.category_id
    ), updated_payments AS (
    UPDATE payments
    SET category_id = (
      SELECT r.category_id
      FROM rules r
      WHERE r.user_id = $1
        AND (r.counterparty_filter IS NULL OR payments.counterparty LIKE '%' || r.counterparty_filter || '%')
        AND (r.note_filter IS NULL OR payments.note LIKE '%' || r.note_filter || '%')
      ORDER BY r.id
      LIMIT 1
    )
    WHERE EXISTS (
      SELECT 1 FROM accounts a
      WHERE a.id = payments.account_id AND a.user_id = $1
    )
    )
    SELECT
      (SELECT COUNT(*) FROM stats_data) as updated_count,
      (SELECT COUNT(*) FROM stats_data WHERE category_id IS NULL) as set_to_null_count
    """

    res = Repo.query!(sql, [user_id])

    [[updated_count, set_to_null_count]] = res.rows
    %{applied: updated_count - set_to_null_count, unapplied: set_to_null_count}
  end
end
