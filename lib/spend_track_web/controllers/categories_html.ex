defmodule SpendTrackWeb.CategoriesHTML do
  use SpendTrackWeb, :html

  embed_templates "categories_html/*"

  attr :form, :any, required: true
  attr :id, :string, default: nil
  attr :action, :string, required: true
  attr :method, :string, default: "post"
  attr :class, :string, default: nil
  attr :submit_label, :string
  slot :cancel

  def category_form(assigns) do
    assigns = assign_new(assigns, :submit_label, fn -> default_submit_label(assigns.method) end)

    ~H"""
    <.simple_form
      :let={f}
      id={@id}
      for={@form}
      as={:category}
      action={@action}
      method={@method}
      class={@class}
    >
      <.input field={f[:color]} type="color" label="Color" class="!size-8" />
      <.input field={f[:name]} label="Name" type="text" />
      <.input field={f[:hide_in_analytics]} label="Hide in analytics" type="checkbox" />
      <:actions>
        <.button type="submit">{@submit_label}</.button>
        <%= for cancel <- @cancel do %>
          {render_slot(cancel)}
        <% end %>
      </:actions>
    </.simple_form>
    """
  end

  defp open_form_js do
    JS.show(to: "#new") |> JS.hide(to: "#create-new-button")
  end

  defp hide_form_js do
    JS.hide(to: "#new") |> JS.show(to: "#create-new-button")
  end

  defp default_submit_label("post"), do: "Create"
  defp default_submit_label(_method), do: "Save"
end
