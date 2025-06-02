defmodule MyPodcasts.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MyPodcastsWeb.Telemetry,
      MyPodcasts.Repo,
      {DNSCluster, query: Application.get_env(:my_podcasts, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: MyPodcasts.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: MyPodcasts.Finch},
      # Start a worker by calling: MyPodcasts.Worker.start_link(arg)
      # {MyPodcasts.Worker, arg},
      # Start to serve requests, typically the last entry
      MyPodcastsWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MyPodcasts.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MyPodcastsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
