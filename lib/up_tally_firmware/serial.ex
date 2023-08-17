defmodule UpTallyFirmware.Serial do
  use GenServer

  require Logger

  alias UpTallyFirmware.Serial

  @buffer_delay 100

  @type t :: %__MODULE__{
          uart_pid: integer(),
          status: atom(),
          timer: integer(),
          buffer_timer: reference(),
          response_buffer: binary()
        }

  defstruct [:uart_pid, :status, :timer, :buffer_timer, :response_buffer]

  def start_link(_),
    do:
      GenServer.start_link(__MODULE__, %UpTallyFirmware.Serial{response_buffer: <<>>},
        name: __MODULE__
      )

  def init(state) do
    Logger.debug("Starting Serial Genserver")
    {:ok, pid} = Circuits.UART.start_link()

    case Circuits.UART.open(pid, "tty.usbserial-B000318B",
           speed: 38400,
           active: true,
           parity: :even
         ) do
      :ok ->
        Circuits.UART.configure(pid, rx_framing_timeout: 500)

        Circuits.UART.configure(pid,
          framing: Circuits.UART.Framing.None
        )

        {:ok}

      {:error, :einval} ->
        Circuits.UART.close(pid)
        {:error, "Failed to open port"}
    end

    {:ok,
     %Serial{
       state
       | uart_pid: pid,
         buffer_timer: Process.send_after(self(), :process_buffer, @buffer_delay)
     }}
  end

  def handle_info(
        {:circuits_uart, _port, {:partial, data}},
        %{response_buffer: response_buffer} = state
      ) do
    {:noreply, %UpTallyFirmware.Serial{state | response_buffer: response_buffer <> data}}
  end

  def handle_info({:circuits_uart, _port, data}, %{response_buffer: response_buffer} = state) do
    {:noreply, %UpTallyFirmware.Serial{state | response_buffer: response_buffer <> data}}
  end

  def handle_info(:process_buffer, state) do
    {:noreply, state |> process_buffer()}
  end

  #   defp process_buffer(%{response_buffer: response_buffer} = state)
  #      when byte_size(response_buffer) >= 558 do
  #   File.write("./buffer", response_buffer)
  #   %{state | buffer_timer: Process.send_after(self(), :process_buffer, @buffer_delay)}
  # end

  # defp process_buffer(state) do
  #   %{state | buffer_timer: Process.send_after(self(), :process_buffer, @buffer_delay)}
  # end

  defp process_buffer(%{response_buffer: response_buffer} = state)
       when byte_size(response_buffer) >= 22 do
    <<
      address::unsigned-integer-size(8),
      _tally::integer-size(8),
      umd::binary-size(16),
      chksum::unsigned-integer-size(8),
      vbc::unsigned-integer-size(8),
      xdata_1::unsigned-integer-size(8),
      _xdata_2::binary-size(1),
      rest::binary
    >> = response_buffer

    # <<
    #   _address::unsigned-integer-size(8),
    #   rest::binary
    # >> = response_buffer

    # IO.inspect("\r")
    # IO.inspect(address)
    # IO.inspect(tally)
    # IO.inspect(umd)
    # IO.inspect(String.valid?(umd))

    %{
      state
      | response_buffer: rest,
        buffer_timer: Process.send_after(self(), :process_buffer, @buffer_delay)
    }

    if String.valid?(umd) == true and (address - 128 >= 0 and address - 128 <= 126) do
      Logger.debug(
        "Address: #{address - 128} Tally:#{set_tally_colour(xdata_1)} UMD:#{umd} Checksum:#{chksum} VBS:#{vbc}"
      )

      # tally =
      %{
        state
        | response_buffer: rest,
          buffer_timer: Process.send_after(self(), :process_buffer, @buffer_delay)
      }
    else
      <<
        _address::unsigned-integer-size(8),
        rest::binary
      >> = response_buffer

      %{
        state
        | response_buffer: rest,
          buffer_timer: Process.send_after(self(), :process_buffer, @buffer_delay)
      }
    end
  end

  defp process_buffer(state) do
    # IO.inspect(response_buffer)
    %{state | buffer_timer: Process.send_after(self(), :process_buffer, @buffer_delay)}
  end

  def as_string(binary) do
    for(<<x::size(1) <- binary>>, do: "#{x}")
    # |> Enum.reverse()
  end

  def set_tally_colour(data) do
    data
    |> bitshift()
    |> set_tally()
  end

  defp bitshift(data) do
    Bitwise.band(data, 3)
  end

  def set_tally(value) when value == 0 do
    :none
  end

  def set_tally(value) when value == 1 do
    :red
  end

  def set_tally(value) when value == 2 do
    :green
  end

  def set_tally(value) when value == 3 do
    :amber
  end
end
