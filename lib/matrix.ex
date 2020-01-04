defmodule Matrix do
  def write(text, x \\ 1, y \\ -1) do
    Matrix.ArrayServer.write(text, x, y)
  end

  def scroll(text, times \\ 10, delay \\ 100) do
    Matrix.ScrollServer.scroll(text, times, delay)
  end
end
