defmodule SpendTrackWeb.RulesController do
  use SpendTrackWeb, :controller

  alias SpendTrack.Rules
  alias SpendTrack.Categories
  alias SpendTrack.Model.Rule

  def index(conn, _params) do
    rules = Rules.list_rules()

    render(conn, :index, rules: rules)
  end

  def new(conn, _params) do
    categories = Categories.list_categories()

    render(conn, :new,
      rule: %Rule{},
      categories: categories,
      form: Phoenix.Component.to_form(Rules.change_rule(%Rule{}), as: :rule)
    )
  end

  def create(conn, %{"rule" => rule_params}) do
    attrs = Map.take(rule_params, ["name", "category_id", "counterparty_filter", "note_filter"])

    case Rules.create_rule(attrs) do
      {:ok, _rule} ->
        conn
        |> put_flash(:info, "Rule created successfully.")
        |> redirect(to: ~p"/rules")

      {:error, %Ecto.Changeset{} = changeset} ->
        categories = Categories.list_categories()

        conn
        |> put_flash(:error, "Could not create rule.")
        |> render(:new,
          rule: %Rule{},
          categories: categories,
          form: Phoenix.Component.to_form(changeset, as: :rule)
        )
    end
  end

  def edit(conn, %{"id" => id}) do
    rule = Rules.get_rule!(id)
    categories = Categories.list_categories()

    render(conn, :edit,
      rule: rule,
      categories: categories,
      form: Phoenix.Component.to_form(Rules.change_rule(rule), as: :rule)
    )
  end

  def update(conn, %{
        "id" => id,
        "rule" => rule_params
      }) do
    rule = Rules.get_rule!(id)

    attrs = Map.take(rule_params, ["name", "category_id", "counterparty_filter", "note_filter"])

    case Rules.update_rule(rule, attrs) do
      {:ok, _rule} ->
        conn
        |> put_flash(:info, "Rule updated successfully.")
        |> redirect(to: ~p"/rules")

      {:error, %Ecto.Changeset{} = changeset} ->
        categories = Categories.list_categories()

        conn
        |> put_flash(:error, "Could not update rule.")
        |> render(:edit,
          rule: rule,
          categories: categories,
          form: Phoenix.Component.to_form(changeset, as: :rule)
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    rule = Rules.get_rule!(id)

    case Rules.delete_rule(rule) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Rule deleted successfully.")
        |> redirect(to: ~p"/rules")

      {:error, _} ->
        conn
        |> put_flash(:error, "Could not delete rule.")
        |> redirect(to: ~p"/rules")
    end
  end
end
