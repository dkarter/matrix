defmodule Matrix.ScrollServer do
  use GenServer

  require Logger

  alias Matrix.FontServer

  @matrix_width 35
  @matrix_y -1

  @doc false
  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(nil) do
    {:ok, %{}}
  end

  @impl true
  def handle_cast({:scroll, params}, _state) do
    %{text: text, times: times, delay: delay} = params

    state = %{
      text: text,
      times: times,
      delay: delay,
      x_min: @matrix_width,
      x_max: -1 * text_width(text),
      x: @matrix_width
    }

    Logger.debug("before send")
    send(self(), :scroll)
    Logger.debug("after send")

    {:noreply, state}
  end

  @impl true
  def handle_info(:scroll, %{x: x, x_max: x_max} = state) when x > x_max do
    Logger.debug("x > x_max, state: #{inspect(state)}")
    Matrix.ArrayServer.write(state.text, x, @matrix_y)
    Process.send_after(self(), :scroll, state.delay)
    {:noreply, %{state | x: x - 1}}
  end

  @impl true
  def handle_info(:scroll, %{times: times} = state) when times > 0 do
    Logger.debug("times > 0, state: #{inspect(state)}")
    Process.send_after(self(), :scroll, state.delay)
    {:noreply, %{state | x: state.x_min, times: state.times - 1}}
  end

  @impl true
  def handle_info(:scroll, state) do
    Logger.debug("last iteration, state: #{inspect(state)}")
    {:noreply, state}
  end

  def scroll(text, times, delay) do
    params = %{text: text, times: times, delay: delay}
    GenServer.cast(__MODULE__, {:scroll, params})
  end

  defp text_width(text) do
    font = FontServer.get()
    Chisel.Renderer.get_text_width(text, font)
  end
end
