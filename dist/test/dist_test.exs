defmodule DISTTest do
  use ExUnit.Case
  doctest DIST

  test "greets the world" do
    assert DIST.hello() == :world
  end
end
