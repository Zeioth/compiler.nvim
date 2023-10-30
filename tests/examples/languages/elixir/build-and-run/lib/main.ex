defmodule Main do
  @moduledoc """
  Documentation for `Main`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Main.hello()
      :world

  """
  def run do
    message = Helper.get_hello()
    IO.puts(message)
  end
end

# Entry point of the program
Main.run()
