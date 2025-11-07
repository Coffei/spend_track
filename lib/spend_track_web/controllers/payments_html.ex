defmodule SpendTrackWeb.PaymentsHTML do
  use SpendTrackWeb, :html

  embed_templates "payments_html/*"

  attr :payments, :list, required: true
  attr :account_id, :integer, default: nil
  attr :show_account, :boolean, default: true

  def payment_list(assigns) do
    ~H"""
    <%= if Enum.empty?(@payments) do %>
      <p class="text-gray-600">No payments yet.</p>
    <% else %>
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th
                :if={@show_account}
                class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
              >
                Account
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Time
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Counterparty & Note
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-right text-gray-500 uppercase tracking-wider">
                Amount
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-right text-gray-500 uppercase tracking-wider">
                Actions
              </th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr :for={payment <- @payments} class="hover:bg-gray-50">
              <td :if={@show_account} class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                <div class="flex items-center gap-2">
                  <span
                    class="inline-block size-6 rounded"
                    style={"background-color: #{payment.account.color}"}
                  />
                  <.link
                    navigate={~p"/accounts/#{payment.account}"}
                    class="text-sm font-medium text-gray-900 hover:text-blue-600"
                  >
                    {payment.account.name}
                  </.link>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                {DateTime.to_string(payment.time)
                |> String.replace("T", " ")
                |> String.slice(0, 16)}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                <p>{payment.counterparty}</p>
                <p class="text-small text-gray-700">{payment.note}</p>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-right text-sm text-gray-900">
                {payment.amount} {payment.currency}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-right text-sm">
                <div class="flex items-center justify-end gap-4">
                  <.link
                    navigate={
                      ~p"/payments/#{payment.id}/edit?#{if @account_id, do: %{account_id: @account_id}, else: %{}}"
                    }
                    class="text-blue-600 hover:text-blue-700 font-medium"
                  >
                    Edit
                  </.link>
                  <.link
                    href={
                      ~p"/payments/#{payment.id}?#{if @account_id, do: %{account_id: @account_id}, else: %{}}"
                    }
                    method="delete"
                    class="text-red-600 hover:text-red-700 font-medium"
                    data-confirm="Are you sure?"
                  >
                    Delete
                  </.link>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    <% end %>
    """
  end

  attr :form, :any, required: true
  attr :accounts, :list, required: true
  attr :account_id, :integer, default: nil
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
      <.input type="hidden" name="account_id" value={@account_id} />
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
