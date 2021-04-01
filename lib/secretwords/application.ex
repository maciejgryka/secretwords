defmodule Secretwords.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      SecretwordsWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Secretwords.PubSub},
      # Start the Endpoint (http/https)
      SecretwordsWeb.Endpoint,
      # Start a worker by calling: Secretwords.Worker.start_link(arg)
      # {Secretwords.Worker, arg}
      Secretwords.GameStore,
      Secretwords.UserStore
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Secretwords.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SecretwordsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
