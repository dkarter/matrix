defmodule Matrix.FontServer do
  use GenServer

  @doc false
  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(nil) do
    Chisel.Font.load("/etc/simple.bdf")
  end

  @impl true
  def handle_call(:get, _from, font) do
    {:reply, font, font}
  end

  def get do
    GenServer.call(__MODULE__, :get)
  end
end
