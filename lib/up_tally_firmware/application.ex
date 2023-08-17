defmodule UpTallyFirmware.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  require Logger

  @impl true
  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: UpTallyFirmware.Supervisor]

    children =
      [
        # Children for all targets
        # Starts a worker by calling: UpTallyFirmware.Worker.start_link(arg)
        # {UpTallyFirmware.Worker, arg},
        {Delux,
         indicators: Application.fetch_env!(:up_tally_firmware, :indicators)},
        UpTallyFirmware.Lights
      ] ++ children(target())

    Supervisor.start_link(children, opts)
  end

  # List all child processes to be supervised
  def children(:host) do
    [
      # Children that only run on the host
      # Starts a worker by calling: UpTallyFirmware.Worker.start_link(arg)
      # {UpTallyFirmware.Worker, arg},
    ]
  end

  def children(_target) do
    [
      # Children for all targets except host
      # Starts a worker by calling: UpTallyFirmware.Worker.start_link(arg)
      # {UpTallyFirmware.Worker, arg},
    ]
  end

  def target() do
    Application.get_env(:up_tally_firmware, :target)
  end
end
