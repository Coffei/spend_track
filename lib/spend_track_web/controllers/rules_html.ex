defmodule SpendTrackWeb.RulesHTML do
  use SpendTrackWeb, :html

  embed_templates "rules_html/*"

  attr :form, :any, required: true
  attr :categories, :list, required: true
  attr :id, :string, default: nil
  attr :method, :string, default: "post"
  attr :class, :string, default: nil
  attr :submit_label, :string
  attr :phx_change, :string, default: nil
  attr :phx_submit, :string, default: nil
  slot :cancel

  def rule_form(assigns) do
    assigns = assign_new(assigns, :submit_label, fn -> default_submit_label(assigns.method) end)

    ~H"""
    <.simple_form
      :let={f}
      id={@id}
      for={@form}
      as={:rule}
      phx-change={@phx_change}
      phx-submit={@phx_submit}
      class={@class}
    >
      <.input field={f[:name]} label="Name" type="text" />
      <.input
        field={f[:category_id]}
        type="select"
        label="Category"
        options={Enum.map(@categories, fn category -> {category.name, category.id} end)}
        prompt="Select a category"
      />
      <.input
        field={f[:counterparty_filter]}
        type="text"
        label="Counterparty Filter"
        placeholder="Optional: filter by counterparty"
      />
      <.input
        field={f[:note_filter]}
        type="textarea"
        label="Note Filter"
        placeholder="Optional: filter by note"
      />
      <:actions>
        <.button type="submit">{@submit_label}</.button>
        <%= for cancel <- @cancel do %>
          {render_slot(cancel)}
        <% end %>
      </:actions>
    </.simple_form>
    """
  end

  defp default_submit_label("post"), do: "Create"
  defp default_submit_label(_method), do: "Save"
end
