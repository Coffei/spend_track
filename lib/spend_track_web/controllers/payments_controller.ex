defmodule SpendTrackWeb.PaymentsController do
  use SpendTrackWeb, :controller

  alias SpendTrack.Payments
  alias SpendTrack.Accounts
  alias SpendTrack.Model.Payment

  def index(%{assigns: %{current_user: current_user}} = conn, _params) do
    payments = Payments.list_payments_by(user_id: current_user.id)
    render(conn, :index, payments: payments)
  end

  def new(%{assigns: %{current_user: current_user}} = conn, params) do
    account_id = params["account_id"]
    accounts = Accounts.list_accounts(current_user.id)

    render(conn, :new,
      accounts: accounts,
      account_id: account_id,
      form:
        Phoenix.Component.to_form(
          Payments.change_payment(%Payment{account_id: account_id}),
          as: :payment
        )
    )
  end

  def create(
        %{assigns: %{current_user: current_user}} = conn,
        %{"payment" => payment_params} = params
      ) do
    attrs =
      payment_params
      |> Map.take(["time", "amount", "currency", "note", "counterparty", "account_id"])

    case Payments.create_payment(attrs) do
      {:ok, _payment} ->
        dbg(params)

        redirect_to =
          if params["account_id"] not in ["", nil],
            do: ~p"/accounts/#{params["account_id"]}",
            else: ~p"/payments"

        conn
        |> put_flash(:info, "Payment created successfully.")
        |> redirect(to: redirect_to)

      {:error, %Ecto.Changeset{} = changeset} ->
        accounts = Accounts.list_accounts(current_user.id)

        conn
        |> put_flash(:error, "Could not create payment.")
        |> render(:new,
          accounts: accounts,
          form: Phoenix.Component.to_form(changeset, as: :payment)
        )
    end
  end

  def delete(%{assigns: %{current_user: current_user}} = conn, %{"id" => id} = params) do
    payments = Payments.list_payments_by(id: String.to_integer(id), user_id: current_user.id)

    redirect_to =
      if params["account_id"] not in ["", nil],
        do: ~p"/accounts/#{params["account_id"]}",
        else: ~p"/payments"

    case payments do
      [payment] ->
        case Payments.delete_payment(payment) do
          {:ok, _} ->
            conn
            |> put_flash(:info, "Payment deleted successfully.")
            |> redirect(to: redirect_to)

          {:error, _} ->
            conn
            |> put_flash(:error, "Could not delete payment.")
            |> redirect(to: redirect_to)
        end

      _ ->
        conn
        |> put_flash(:error, "Payment not found.")
        |> redirect(to: redirect_to)
    end
  end
end
