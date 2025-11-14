defmodule SpendTrack.Payments do
  @moduledoc """
  The Payments context.
  """

  import Ecto.Changeset, only: [get_field: 2, put_change: 3]
  import Ecto.Query, warn: false
  alias SpendTrack.Repo
  alias SpendTrack.Model.Payment
  alias SpendTrack.Rules

  @doc """
  Create a new payment.
  """
  @spec create_payment(map()) :: {:ok, Payment.t()} | {:error, Ecto.Changeset.t()}
  def create_payment(attrs \\ %{}) do
    changeset = Payment.changeset(%Payment{}, attrs)

    temp_payment = %Payment{
      note: get_field(changeset, :note),
      counterparty: get_field(changeset, :counterparty)
    }

    category_id = Rules.find_category_for_payment(temp_payment)

    changeset =
      if category_id do
        put_change(changeset, :category_id, category_id)
      else
        changeset
      end

    Repo.insert(changeset)
  end

  @doc """
  Update an existing payment.
  """
  @spec update_payment(Payment.t(), map()) :: {:ok, Payment.t()} | {:error, Ecto.Changeset.t()}
  def update_payment(%Payment{} = payment, attrs) do
    changeset = Payment.changeset(payment, attrs)

    temp_payment = %Payment{
      note: get_field(changeset, :note),
      counterparty: get_field(changeset, :counterparty)
    }

    category_id = Rules.find_category_for_payment(temp_payment)

    changeset =
      if category_id != get_field(changeset, :category_id) do
        put_change(changeset, :category_id, category_id)
      else
        changeset
      end

    Repo.update(changeset)
  end

  @doc """
  Delete a payment.
  """
  @spec delete_payment(Payment.t()) :: {:ok, Payment.t()} | {:error, Ecto.Changeset.t()}
  def delete_payment(%Payment{} = payment) do
    Repo.delete(payment)
  end

  @doc """
  Returns a changeset for a payment.
  """
  @spec change_payment(Payment.t(), map()) :: Ecto.Changeset.t()
  def change_payment(%Payment{} = payment, attrs \\ %{}) do
    Payment.changeset(payment, attrs)
  end

  @doc """
  Locate payments by conditions provided as a keyword list.

  Supported keys:
  - Equality: :id, :account_id, :currency, :counterparty, :time, :amount
  - Ranges: :time_gte, :time_lte, :amount_gte, :amount_lte
  """
  @spec list_payments_by(Keyword.t()) :: [Payment.t()]
  def list_payments_by(conditions \\ [], limit \\ 100) when is_list(conditions) do
    base =
      from(p in Payment,
        join: a in assoc(p, :account),
        preload: [account: a]
      )

    dynamic =
      Enum.reduce(conditions, true, fn
        {:id, v}, dyn -> dynamic([p], ^dyn and p.id == ^v)
        {:account_id, v}, dyn -> dynamic([p], ^dyn and p.account_id == ^v)
        {:category_id, nil}, dyn -> dynamic([p], ^dyn and is_nil(p.category_id))
        {:category_id, v}, dyn -> dynamic([p], ^dyn and p.category_id == ^v)
        {:currency, v}, dyn -> dynamic([p], ^dyn and p.currency == ^v)
        {:counterparty, v}, dyn -> dynamic([p], ^dyn and p.counterparty == ^v)
        {:time, v}, dyn -> dynamic([p], ^dyn and p.time == ^v)
        {:amount, v}, dyn -> dynamic([p], ^dyn and p.amount == ^v)
        {:time_gte, v}, dyn -> dynamic([p], ^dyn and p.time >= ^v)
        {:time_lte, v}, dyn -> dynamic([p], ^dyn and p.time <= ^v)
        {:amount_gte, v}, dyn -> dynamic([p], ^dyn and p.amount >= ^v)
        {:amount_lte, v}, dyn -> dynamic([p], ^dyn and p.amount <= ^v)
        {:user_id, v}, dyn -> dynamic([_p, a], ^dyn and a.user_id == ^v)
        {_unknown, _}, dyn -> dyn
      end)

    base
    |> where(^dynamic)
    |> order_by(desc: :time, asc: :counterparty, asc: :amount)
    |> limit(^limit)
    |> Repo.all()
  end

  @doc """
  Import a list of payments, deduplicating based on time, amount, currency, and counterparty.

  Returns a tuple with the count of imported payments and the count of skipped duplicates.
  """
  @spec import_payments([map()], integer()) ::
          {:ok, integer(), integer()} | {:error, Ecto.Changeset.t()}
  def import_payments(payment_maps, account_id)
      when is_list(payment_maps) and is_integer(account_id) do
    # Get existing payments for this account to check for duplicates
    # Use a normalized key format for comparison (convert Decimal to string for MapSet)
    existing_payments =
      from(p in Payment,
        where: p.account_id == ^account_id,
        select: {p.time, p.amount, p.currency, p.counterparty}
      )
      |> Repo.all()
      |> Enum.map(fn {time, amount, currency, counterparty} ->
        {time, Decimal.to_float(amount), currency, counterparty}
      end)
      |> MapSet.new()

    # Deduplicate: filter out payments that already exist
    {new_payments, skipped} =
      Enum.reduce(payment_maps, {[], 0}, fn payment_map, {acc, skipped_count} ->
        time = payment_map[:time]
        amount = Decimal.to_float(payment_map[:amount])
        currency = payment_map[:currency]
        counterparty = payment_map[:counterparty]

        key = {time, amount, currency, counterparty}

        if MapSet.member?(existing_payments, key) do
          {acc, skipped_count + 1}
        else
          attrs = Map.put(payment_map, :account_id, account_id)
          {[attrs | acc], skipped_count}
        end
      end)

    # Insert all new payments in a transaction
    result =
      Repo.transaction(fn ->
        Enum.map(new_payments, fn attrs ->
          case create_payment(attrs) do
            {:ok, payment} -> payment
            {:error, changeset} -> Repo.rollback(changeset)
          end
        end)
      end)

    case result do
      {:ok, _payments} ->
        Rules.run_all()
        {:ok, length(new_payments), skipped}

      {:error, changeset} ->
        {:error, changeset}
    end
  end
end
