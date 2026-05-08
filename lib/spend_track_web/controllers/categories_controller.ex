defmodule SpendTrackWeb.CategoriesController do
  use SpendTrackWeb, :controller

  alias SpendTrack.Categories
  alias SpendTrack.Model.Category
  alias SpendTrack.Payments

  def index(%{assigns: %{current_user: current_user}} = conn, _params) do
    categories = Categories.list_categories(current_user.id)

    render(conn, :index,
      categories: categories,
      other_payment_count: Categories.count_other_payments(current_user.id),
      form: Phoenix.Component.to_form(Categories.change_category(%Category{}), as: :category)
    )
  end

  def show(%{assigns: %{current_user: current_user}} = conn, %{"id" => "other"}) do
    payments = Payments.list_payments_by([user_id: current_user.id, category_id: nil], 1000)
    render(conn, "show.html", payments: payments, category: nil)
  end

  def show(%{assigns: %{current_user: current_user}} = conn, %{"id" => id}) do
    category = Categories.get_category!(id, current_user.id)

    payments =
      Payments.list_payments_by([user_id: current_user.id, category_id: category.id], 1000)

    render(conn, "show.html", payments: payments, category: category)
  end

  def create(%{assigns: %{current_user: current_user}} = conn, %{"category" => category_params}) do
    attrs = Map.take(category_params, ["color", "name"])

    case Categories.create_category(current_user.id, attrs) do
      {:ok, _category} ->
        conn
        |> put_flash(:info, "Category created successfully.")
        |> redirect(to: ~p"/categories")

      {:error, %Ecto.Changeset{} = changeset} ->
        categories = Categories.list_categories(current_user.id)

        conn
        |> put_flash(:error, "Could not create category.")
        |> render(:index,
          categories: categories,
          form: Phoenix.Component.to_form(changeset, as: :category)
        )
    end
  end

  def edit(%{assigns: %{current_user: current_user}} = conn, %{"id" => id}) do
    category = Categories.get_category!(id, current_user.id)

    render(conn, :edit,
      category: category,
      form: Phoenix.Component.to_form(Categories.change_category(category), as: :category)
    )
  end

  def update(%{assigns: %{current_user: current_user}} = conn, %{
        "id" => id,
        "category" => category_params
      }) do
    category = Categories.get_category!(id, current_user.id)

    attrs = Map.take(category_params, ["color", "name", "hide_in_analytics"])

    case Categories.update_category(category, attrs) do
      {:ok, _category} ->
        conn
        |> put_flash(:info, "Category updated successfully.")
        |> redirect(to: ~p"/categories")

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Could not update category.")
        |> render(:edit,
          category: category,
          form: Phoenix.Component.to_form(changeset, as: :category)
        )
    end
  end

  def delete(%{assigns: %{current_user: current_user}} = conn, %{"id" => id}) do
    category = Categories.get_category!(id, current_user.id)

    case Categories.delete_category(category) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Category deleted successfully.")
        |> redirect(to: ~p"/categories")

      {:error, _} ->
        conn
        |> put_flash(:error, "Could not delete category.")
        |> redirect(to: ~p"/categories")
    end
  end
end
