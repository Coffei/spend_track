defmodule SpendTrackWeb.RulesController do
  use SpendTrackWeb, :controller

  alias SpendTrack.Rules

  def index(%{assigns: %{current_user: current_user}} = conn, _params) do
    rules = Rules.list_rules(current_user.id)

    render(conn, :index, rules: rules)
  end

  def delete(%{assigns: %{current_user: current_user}} = conn, %{"id" => id}) do
    rule = Rules.get_rule!(id, current_user.id)

    case Rules.delete_rule(rule) do
      {:ok, _, %{applied: set, unapplied: unset}} ->
        stats_message = "Category set to #{set} payments, and unset from #{unset} payments."

        conn
        |> put_flash(:info, "Rule deleted successfully. #{stats_message}")
        |> redirect(to: ~p"/rules")

      {:error, _} ->
        conn
        |> put_flash(:error, "Could not delete rule.")
        |> redirect(to: ~p"/rules")
    end
  end
end
