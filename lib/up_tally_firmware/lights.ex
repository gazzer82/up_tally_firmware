defmodule UpTallyFirmware.Lights do
  use GenServer
  @name __MODULE__

  require Logger

  @phoenix_channel "status"

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    Logger.debug("Starting status lights server")

    case Phoenix.PubSub.subscribe(UpTally.PubSub, @phoenix_channel) do
      :ok ->
        Logger.debug("Subscribed to Phoenix Pubsub channel #{@phoenix_channel}")
        {:ok, %{}}

      {:error, term} ->
        Logger.error("Failed to staert status lights server.")
        IO.inspect(term)
        {:stop, term}
    end
  end

  def handle_info({:atem_status, status}, state) do
    Logger.debug("Atem Status: #{Atom.to_string(status)}")

    case status do
      :connecting ->
        Delux.render(
          %{
            default: Delux.Effects.on(:cyan)
          },
          :status
        )

      :connected ->
        Delux.render(
          %{
            default: Delux.Effects.on(:green)
          },
          :status
        )

      :disconnected ->
        Delux.render(
          %{
            default: Delux.Effects.on(:red)
          },
          :status
        )

      :transmitting ->
        Delux.render(
          %{
            default: Delux.Effects.blip(:magenta, :white)
          },
          :notification
        )

      :recieving ->
        Delux.render(
          %{
            default: Delux.Effects.blip(:yellow, :white)
          },
          :notification
        )
    end

    {:noreply, state}
  end

  def handle_info({:tsl_status, status}, state) do
    Logger.debug("TSL Status: #{Atom.to_string(status)}")

    case status do
      :connecting ->
        Delux.render(
          %{
            rgb2: Delux.Effects.on(:cyan)
          },
          :status
        )

      :connected ->
        Delux.render(
          %{
            rgb2: Delux.Effects.on(:green)
          },
          :status
        )

      :disconnected ->
        Delux.render(
          %{
            rgb2: Delux.Effects.on(:red)
          },
          :status
        )

      :transmitting ->
        Delux.render(
          %{
            rgb2: Delux.Effects.blip(:magenta, :white)
          },
          :notification
        )

      :recieving ->
        Delux.render(
          %{
            rgb2: Delux.Effects.blip(:yellow, :white)
          },
          :notification
        )
    end

    {:noreply, state}
  end

  def handle_info(event, state) do
    IO.inspect(event)
    {:noreply, state}
  end
end
