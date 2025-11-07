defmodule SpendTrackWeb.PaymentsHTML do
  use SpendTrackWeb, :html

  embed_templates "payments_html/*"

  attr :form, :any, required: true
  attr :accounts, :list, required: true
  attr :id, :string, default: nil
  attr :action, :string, required: true
  attr :method, :string, default: "post"
  attr :class, :string, default: nil
  attr :submit_label, :string, default: "Create"

  def payment_form(assigns) do
    ~H"""
    <.simple_form
      :let={f}
      id={@id}
      for={@form}
      as={:payment}
      action={@action}
      method={@method}
      class={@class}
    >
      <.input
        field={f[:account_id]}
        type="select"
        label="Account"
        options={Enum.map(@accounts, fn account -> {account.name, account.id} end)}
      />
      <.input field={f[:time]} type="datetime-local" label="Time" />
      <.input field={f[:amount]} type="number" label="Amount" step="0.01" />
      <.input field={f[:currency]} type="text" label="Currency" />
      <.input field={f[:counterparty]} type="text" label="Counterparty" />
      <.input field={f[:note]} type="textarea" label="Note" />
      <:actions>
        <.button type="submit">{@submit_label}</.button>
      </:actions>
    </.simple_form>
    """
  end
end
