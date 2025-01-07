defmodule ClientRegistration.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ClientRegistrationWeb.Telemetry,
      ClientRegistration.Repo,
      {DNSCluster, query: Application.get_env(:client_registration, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ClientRegistration.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ClientRegistration.Finch},
      # Start a worker by calling: ClientRegistration.Worker.start_link(arg)
      # {ClientRegistration.Worker, arg},
      # Start to serve requests, typically the last entry
      ClientRegistrationWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ClientRegistration.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ClientRegistrationWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
