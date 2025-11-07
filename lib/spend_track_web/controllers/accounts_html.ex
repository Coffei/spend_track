defmodule SpendTrackWeb.AccountsHTML do
  use SpendTrackWeb, :html

  embed_templates "accounts_html/*"

  defp open_form_js do
    JS.show(to: "#new") |> JS.hide(to: "#create-new-button")
  end

  defp hide_form_js do
    JS.hide(to: "#new") |> JS.show(to: "#create-new-button")
  end
end
