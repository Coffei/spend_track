defmodule SpendTrackWeb.RuleLive.Form do
  use SpendTrackWeb, :live_view

  alias SpendTrack.Rules
  alias SpendTrack.Categories
  alias SpendTrack.Model.Rule

  import SpendTrackWeb.RulesHTML

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {rule, page_title, submit_label, form_id} =
      case params do
        %{"id" => id} ->
          rule = Rules.get_rule!(id)
          {rule, "Edit rule", "Save changes", "edit-rule-form"}

        _ ->
          {%Rule{}, "Create new rule", "Create", "new-rule-form"}
      end

    categories = Categories.list_categories()
    changeset = Rules.change_rule(rule)

    {:noreply,
     socket
     |> assign(:page_title, page_title)
     |> assign(:rule, rule)
     |> assign(:categories, categories)
     |> assign(:form, to_form(changeset, as: :rule))
     |> assign(:submit_label, submit_label)
     |> assign(:form_id, form_id)}
  end

  @impl true
  def handle_event("validate", %{"rule" => rule_params}, socket) do
    attrs = Map.take(rule_params, ["name", "category_id", "counterparty_filter", "note_filter"])

    changeset =
      socket.assigns.rule
      |> Rules.change_rule(attrs)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset, as: :rule))}
  end

  @impl true
  def handle_event("save", %{"rule" => rule_params}, socket) do
    attrs = Map.take(rule_params, ["name", "category_id", "counterparty_filter", "note_filter"])

    result =
      if socket.assigns.rule.id do
        Rules.update_rule(socket.assigns.rule, attrs)
      else
        Rules.create_rule(attrs)
      end

    case result do
      {:ok, _rule} ->
        message =
          if socket.assigns.rule.id,
            do: "Rule updated successfully.",
            else: "Rule created successfully."

        {:noreply,
         socket
         |> put_flash(:info, message)
         |> push_navigate(to: ~p"/rules")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset, as: :rule))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-2xl mx-auto py-6">
      <h1 class="text-2xl font-semibold mb-4">{@page_title}</h1>

      <.rule_form
        id={@form_id}
        form={@form}
        categories={@categories}
        phx_change="validate"
        phx_submit="save"
        submit_label={@submit_label}
      >
        <:cancel>
          <.link
            navigate={~p"/rules"}
            class="ml-2 text-sm font-medium text-zinc-600 hover:text-zinc-900"
          >
            Cancel
          </.link>
        </:cancel>
      </.rule_form>
    </div>
    """
  end
end
