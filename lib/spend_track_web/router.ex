defmodule SpendTrackWeb.Router do
  use SpendTrackWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SpendTrackWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug SpendTrackWeb.Plugs.FetchCurrentUser
  end

  pipeline :authenticated do
    plug SpendTrackWeb.Plugs.RequireUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SpendTrackWeb do
    pipe_through :browser

    get "/", PageController, :home

    get "/auth/:provider", AuthController, :request
    get "/auth/:provider/callback", AuthController, :callback
    delete "/logout", AuthController, :delete
  end

  scope "/", SpendTrackWeb do
    pipe_through :browser
    pipe_through :authenticated

    live_session :authenticated do
      get "/accounts", AccountsController, :index
      post "/accounts", AccountsController, :create
      get "/accounts/:id/edit", AccountsController, :edit
      get "/accounts/:id", AccountsController, :show
      patch "/accounts/:id", AccountsController, :update
      delete "/accounts/:id", AccountsController, :delete

      get "/payments", PaymentsController, :index
      get "/payments/new", PaymentsController, :new
      post "/payments", PaymentsController, :create
      get "/payments/import", PaymentsController, :import
      post "/payments/import", PaymentsController, :do_import
      get "/payments/:id/edit", PaymentsController, :edit
      patch "/payments/:id", PaymentsController, :update
      delete "/payments/:id", PaymentsController, :delete

      get "/categories", CategoriesController, :index
      post "/categories", CategoriesController, :create
      get "/categories/:id/edit", CategoriesController, :edit
      patch "/categories/:id", CategoriesController, :update
      delete "/categories/:id", CategoriesController, :delete

      get "/rules", RulesController, :index
      live "/rules/new", RuleLive.Form, :new
      live "/rules/:id/edit", RuleLive.Form, :edit
      delete "/rules/:id", RulesController, :delete
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", SpendTrackWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard in development
  if Application.compile_env(:spend_track, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: SpendTrackWeb.Telemetry
    end
  end
end
