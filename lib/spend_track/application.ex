defmodule SpendTrack.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SpendTrackWeb.Telemetry,
      SpendTrack.Repo,
      {DNSCluster, query: Application.get_env(:spend_track, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: SpendTrack.PubSub},
      # Start a worker by calling: SpendTrack.Worker.start_link(arg)
      # {SpendTrack.Worker, arg},
      # Start to serve requests, typically the last entry
      SpendTrackWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SpendTrack.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SpendTrackWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
