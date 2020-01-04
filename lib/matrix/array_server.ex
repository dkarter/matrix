defmodule Matrix.ArrayServer do
  alias Matrix.FontServer

  use GenServer

  @doc false
  def start_link([]) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_) do
    {:ok, ref} = Max72XX.Array.start_link("spidev0.0", 4)
    {:ok, %{ref: ref}}
  end

  @impl true
  def handle_cast(:clear, state) do
    %{ref: ref} = state
    Max72XX.Array.clear(ref)
    {:noreply, state}
  end

  @impl true
  def handle_cast({:set, x, y}, state) do
    %{ref: ref} = state
    Max72XX.Array.set_pixel(ref, x, y)
    {:noreply, state}
  end

  @impl true
  def handle_cast(:update, state) do
    %{ref: ref} = state
    Max72XX.Array.update(ref)
    {:noreply, state}
  end

  # ----------------------------

  def clear do
    GenServer.cast(__MODULE__, :clear)
  end

  def set(x, y) do
    GenServer.cast(__MODULE__, {:set, x, y})
  end

  def update do
    GenServer.cast(__MODULE__, :update)
  end

  def write(text, x, y) do
    put_pixel = fn x, y ->
      set(x, y)
    end

    font = FontServer.get()

    clear()
    Chisel.Renderer.draw_text(text, x, y, font, put_pixel)
    update()
  end
end
