defmodule SpendTrackWeb.RuleLive.Form do
  use SpendTrackWeb, :live_view

  alias SpendTrack.Payments
  alias SpendTrack.Rules
  alias SpendTrack.Categories
  alias SpendTrack.Model.Rule

  import SpendTrackWeb.RulesHTML
  import SpendTrackWeb.PaymentsHTML, only: [payment_list: 1]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {rule, page_title, submit_label, form_id, preview_payments} =
      case params do
        %{"id" => id} ->
          rule = Rules.get_rule!(id)
          preview_payments = Rules.find_matching_payments(rule)
          {rule, "Edit rule", "Save changes", "edit-rule-form", preview_payments}

        _ ->
          {%Rule{}, "Create new rule", "Create", "new-rule-form", []}
      end

    categories = Categories.list_categories()
    changeset = Rules.change_rule(rule)

    other_payments =
      Payments.list_payments_by([user_id: socket.assigns.current_user.id, category_id: nil], 20)

    {:noreply,
     socket
     |> assign(:page_title, page_title)
     |> assign(:rule, rule)
     |> assign(:categories, categories)
     |> assign(:form, to_form(changeset, as: :rule))
     |> assign(:submit_label, submit_label)
     |> assign(:form_id, form_id)
     |> assign(:preview_loading, false)
     |> assign(:preview_payments, preview_payments)
     |> assign(:other_payments, other_payments)}
  end

  @impl true
  def handle_event("validate", %{"rule" => rule_params}, socket) do
    attrs = Map.take(rule_params, ["name", "category_id", "counterparty_filter", "note_filter"])

    changeset =
      socket.assigns.rule
      |> Rules.change_rule(attrs)
      |> Map.put(:action, :validate)

    socket =
      socket
      |> assign(:form, to_form(changeset, as: :rule))
      |> init_preview_payments()

    {:noreply, socket}
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
      {:ok, _rule, %{applied: set, unapplied: unset}} ->
        stats_message = "Category set to #{set} payments, and unset from #{unset} payments."

        message =
          if socket.assigns.rule.id,
            do: "Rule updated successfully. #{stats_message}",
            else: "Rule created successfully. #{stats_message}"

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
    <div :if={@preview_loading || @preview_payments != []} class="mt-8 max-w-4xl mx-auto">
      <h2 class="text-lg font-semibold mb-4">Preview Matching Payments</h2>
      <p class="text-sm text-gray-600 mb-4">The first 20 matching payments will be shown.</p>
      <p :if={@preview_loading} class="mb-4">Loading...</p>
      <.payment_list :if={@preview_payments != []} payments={@preview_payments} show_actions={false} />
    </div>
    <div :if={@other_payments != []} class="mt-8 max-w-4xl mx-auto">
      <h2 class="text-lg font-semibold mb-4">Payments without a category</h2>
      <p class="text-sm text-gray-600 mb-4">
        The first 20 payments without a category will be shown.
      </p>
      <.payment_list :if={@other_payments != []} payments={@other_payments} show_actions={false} />
    </div>
    <p :if={@other_payments == []} class="mt-8">All payments are categorized already.</p>
    """
  end

  @empty_params %{"counterparty_filter" => "", "note_filter" => ""}
  @impl true
  def handle_info({:preview_payments, params}, socket) do
    current_params = Map.take(socket.assigns.form.params, ["counterparty_filter", "note_filter"])

    socket =
      cond do
        params == @empty_params ->
          socket
          |> assign(:preview_payments, [])
          |> assign(:preview_loading, false)

        params == current_params ->
          rule = %Rule{
            counterparty_filter: params["counterparty_filter"],
            note_filter: params["note_filter"]
          }

          payments = Rules.find_matching_payments(rule)

          socket
          |> assign(:preview_payments, payments)
          |> assign(:preview_loading, false)

        true ->
          socket
      end

    {:noreply, socket}
  end

  defp init_preview_payments(socket) do
    params = Map.take(socket.assigns.form.params, ["counterparty_filter", "note_filter"])
    Process.send_after(self(), {:preview_payments, params}, 500)
    assign(socket, preview_loading: true)
  end
end
