defmodule MainTest do
  use ExUnit.Case
  doctest Main

  test "greets the world" do
    assert Main.hello() == :world
  end
end
