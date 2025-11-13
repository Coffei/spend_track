defmodule SpendTrackWeb.RulesController do
  use SpendTrackWeb, :controller

  alias SpendTrack.Rules

  def index(conn, _params) do
    rules = Rules.list_rules()

    render(conn, :index, rules: rules)
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
