defmodule SpendTrackWeb.CategoriesController do
  use SpendTrackWeb, :controller

  alias SpendTrack.Categories
  alias SpendTrack.Model.Category

  def index(conn, _params) do
    categories = Categories.list_categories()

    render(conn, :index,
      categories: categories,
      other_payment_count: Categories.count_other_payments(),
      form: Phoenix.Component.to_form(Categories.change_category(%Category{}), as: :category)
    )
  end

  def create(conn, %{"category" => category_params}) do
    attrs = Map.take(category_params, ["color", "name"])

    case Categories.create_category(attrs) do
      {:ok, _category} ->
        conn
        |> put_flash(:info, "Category created successfully.")
        |> redirect(to: ~p"/categories")

      {:error, %Ecto.Changeset{} = changeset} ->
        categories = Categories.list_categories()

        conn
        |> put_flash(:error, "Could not create category.")
        |> render(:index,
          categories: categories,
          form: Phoenix.Component.to_form(changeset, as: :category)
        )
    end
  end

  def edit(conn, %{"id" => id}) do
    category = Categories.get_category!(id)

    render(conn, :edit,
      category: category,
      form: Phoenix.Component.to_form(Categories.change_category(category), as: :category)
    )
  end

  def update(conn, %{
        "id" => id,
        "category" => category_params
      }) do
    category = Categories.get_category!(id)

    attrs = Map.take(category_params, ["color", "name"])

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

  def delete(conn, %{"id" => id}) do
    category = Categories.get_category!(id)

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
