defmodule Clock.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ClockWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:clock, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Clock.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Clock.Finch},
      # Start a worker by calling: Clock.Worker.start_link(arg)
      # {Clock.Worker, arg},
      # Start to serve requests, typically the last entry

      # Registry for naming GenServers dynamically
      {Registry, keys: :unique, name: Clock.ClockRegistry},
      ClockWeb.Endpoint
    ]

    # See https://hexdocs.pm/eliir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Clock.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ClockWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
