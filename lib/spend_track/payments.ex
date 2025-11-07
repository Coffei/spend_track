defmodule SpendTrack.Payments do
  @moduledoc """
  The Payments context.
  """

  import Ecto.Query, warn: false
  alias SpendTrack.Repo
  alias SpendTrack.Model.Payment

  @doc """
  Create a new payment.
  """
  @spec create_payment(map()) :: {:ok, Payment.t()} | {:error, Ecto.Changeset.t()}
  def create_payment(attrs \\ %{}) do
    %Payment{}
    |> Payment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Update an existing payment.
  """
  @spec update_payment(Payment.t(), map()) :: {:ok, Payment.t()} | {:error, Ecto.Changeset.t()}
  def update_payment(%Payment{} = payment, attrs) do
    payment
    |> Payment.changeset(attrs)
    |> Repo.update()
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
  def list_payments_by(conditions \\ []) when is_list(conditions) do
    base =
      from(p in Payment,
        join: a in assoc(p, :account),
        preload: [account: a]
      )

    dynamic =
      Enum.reduce(conditions, true, fn
        {:id, v}, dyn -> dynamic([p], ^dyn and p.id == ^v)
        {:account_id, v}, dyn -> dynamic([p], ^dyn and p.account_id == ^v)
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
    |> order_by(desc: :time)
    |> limit(100)
    |> Repo.all()
  end
end
