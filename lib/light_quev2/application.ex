defmodule LightQuev2.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised

    children = case Mix.env() == :test do
      true -> [LightQuev2.Repo]
      false-> [LightQuev2.Repo, LightQuev2]
    end


    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LightQuev2.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
