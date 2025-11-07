defmodule SpendTrackWeb.AccountsController do
  use SpendTrackWeb, :controller

  alias SpendTrack.Accounts
  alias SpendTrack.Model.Account

  def index(%{assigns: %{current_user: current_user}} = conn, _params) do
    accounts = Accounts.list_accounts(current_user.id)

    render(conn, :index,
      accounts: accounts,
      form: Phoenix.Component.to_form(Accounts.change_account(%Account{}), as: :account)
    )
  end

  def create(%{assigns: %{current_user: current_user}} = conn, %{"account" => account_params}) do
    attrs =
      account_params
      |> Map.take(["color", "name"])
      |> Map.put("user_id", current_user.id)

    case Accounts.create_account(attrs) do
      {:ok, _account} ->
        conn
        |> put_flash(:info, "Account created successfully.")
        |> redirect(to: ~p"/accounts")

      {:error, %Ecto.Changeset{} = changeset} ->
        accounts = Accounts.list_accounts(current_user.id)

        conn
        |> put_flash(:error, "Could not create account.")
        |> render(:index,
          accounts: accounts,
          form: Phoenix.Component.to_form(changeset, as: :account)
        )
    end
  end

  def edit(conn, %{"id" => id}) do
    account = Accounts.get_account!(id)

    render(conn, :edit,
      account: account,
      form: Phoenix.Component.to_form(Accounts.change_account(account), as: :account)
    )
  end

  def update(conn, %{"id" => id, "account" => account_params}) do
    account = Accounts.get_account!(id)

    attrs = Map.take(account_params, ["color", "name"])

    case Accounts.update_account(account, attrs) do
      {:ok, _account} ->
        conn
        |> put_flash(:info, "Account updated successfully.")
        |> redirect(to: ~p"/accounts")

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Could not update account.")
        |> render(:edit,
          account: account,
          form: Phoenix.Component.to_form(changeset, as: :account)
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    account = Accounts.get_account!(id)

    case Accounts.delete_account(account) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Account deleted successfully.")
        |> redirect(to: ~p"/accounts")

      {:error, _} ->
        conn
        |> put_flash(:error, "Could not delete account.")
        |> redirect(to: ~p"/accounts")
    end
  end
end
