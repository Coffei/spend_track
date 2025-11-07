defmodule SpendTrackWeb.PaymentsController do
  use SpendTrackWeb, :controller

  alias SpendTrack.Payments
  alias SpendTrack.Accounts
  alias SpendTrack.Model.Payment

  def index(%{assigns: %{current_user: current_user}} = conn, _params) do
    payments = Payments.list_payments_by(user_id: current_user.id)
    render(conn, :index, payments: payments)
  end

  def new(%{assigns: %{current_user: current_user}} = conn, _params) do
    accounts = Accounts.list_accounts(current_user.id)

    render(conn, :new,
      accounts: accounts,
      form: Phoenix.Component.to_form(Payments.change_payment(%Payment{}), as: :payment)
    )
  end

  def create(%{assigns: %{current_user: current_user}} = conn, %{"payment" => payment_params}) do
    attrs =
      payment_params
      |> Map.take(["time", "amount", "currency", "note", "counterparty", "account_id"])

    case Payments.create_payment(attrs) do
      {:ok, _payment} ->
        conn
        |> put_flash(:info, "Payment created successfully.")
        |> redirect(to: ~p"/payments")

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
end
