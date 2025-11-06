defmodule SpendTrackWeb.ErrorJSONTest do
  use SpendTrackWeb.ConnCase, async: true

  test "renders 404" do
    assert SpendTrackWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert SpendTrackWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
