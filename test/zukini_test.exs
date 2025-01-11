defmodule ZukiniTest do
  use ExUnit.Case
  doctest Zukini

  test "greets the world" do
    assert Zukini.hello() == :world
  end
end
