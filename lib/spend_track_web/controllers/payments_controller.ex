defmodule SpendTrackWeb.PaymentsController do
  use SpendTrackWeb, :controller

  alias SpendTrack.Payments
  alias SpendTrack.Accounts
  alias SpendTrack.Model.Payment
  alias SpendTrack.Import

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

  def edit(%{assigns: %{current_user: current_user}} = conn, %{"id" => id} = params) do
    payments = Payments.list_payments_by(id: String.to_integer(id), user_id: current_user.id)
    accounts = Accounts.list_accounts(current_user.id)
    account_id = params["account_id"]

    case payments do
      [payment] ->
        render(conn, :edit,
          payment: payment,
          accounts: accounts,
          account_id: account_id,
          form:
            Phoenix.Component.to_form(
              Payments.change_payment(payment),
              as: :payment
            )
        )

      _ ->
        redirect_to =
          if account_id not in ["", nil],
            do: ~p"/accounts/#{account_id}",
            else: ~p"/payments"

        conn
        |> put_flash(:error, "Payment not found.")
        |> redirect(to: redirect_to)
    end
  end

  def update(
        %{assigns: %{current_user: current_user}} = conn,
        %{"id" => id, "payment" => payment_params} = params
      ) do
    payments = Payments.list_payments_by(id: String.to_integer(id), user_id: current_user.id)
    account_id = params["account_id"] || payment_params["account_id"]

    redirect_to =
      if account_id not in ["", nil],
        do: ~p"/accounts/#{account_id}",
        else: ~p"/payments"

    case payments do
      [payment] ->
        attrs =
          payment_params
          |> Map.take(["time", "amount", "currency", "note", "counterparty", "account_id"])

        case Payments.update_payment(payment, attrs) do
          {:ok, _payment} ->
            conn
            |> put_flash(:info, "Payment updated successfully.")
            |> redirect(to: redirect_to)

          {:error, %Ecto.Changeset{} = changeset} ->
            accounts = Accounts.list_accounts(current_user.id)

            conn
            |> put_flash(:error, "Could not update payment.")
            |> render(:edit,
              payment: payment,
              accounts: accounts,
              account_id: account_id,
              form: Phoenix.Component.to_form(changeset, as: :payment)
            )
        end

      _ ->
        conn
        |> put_flash(:error, "Payment not found.")
        |> redirect(to: redirect_to)
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

  def import(%{assigns: %{current_user: current_user}} = conn, params) do
    accounts = Accounts.list_accounts(current_user.id)
    account_id = params["account_id"]

    render(conn, :import,
      accounts: accounts,
      account_id: account_id && String.to_integer(account_id)
    )
  end

  def do_import(%{assigns: %{current_user: current_user}} = conn, %{
        "file" => %Plug.Upload{} = upload,
        "account_id" => account_id
      }) do
    account_id = String.to_integer(account_id)

    # Verify account belongs to user
    try do
      Accounts.get_account!(account_id, current_user.id)

      # Read and parse the CSV file
      csv_content = File.read!(upload.path)

      case Import.csv_to_payments(csv_content) do
        {:ok, payment_maps} ->
          case Payments.import_payments(payment_maps, account_id) do
            {:ok, imported_count, skipped_count} ->
              conn
              |> put_flash(
                :info,
                "Imported #{imported_count} payment(s). #{skipped_count} duplicate(s) skipped."
              )
              |> redirect(to: ~p"/accounts/#{account_id}")

            {:error, changeset} ->
              conn
              |> put_flash(:error, "Error importing payments: #{inspect(changeset.errors)}")
              |> redirect(to: ~p"/payments/import")
          end

        {:error, reason} ->
          conn
          |> put_flash(:error, "Failed to parse CSV file: #{reason}.")
          |> redirect(to: ~p"/payments/import")
      end
    rescue
      Ecto.NoResultsError ->
        conn
        |> put_flash(:error, "Account not found.")
        |> redirect(to: ~p"/payments/import")
    end
  end

  def do_import(conn, _params) do
    conn
    |> put_flash(:error, "Please select a file and account.")
    |> redirect(to: ~p"/payments/import")
  end
end
