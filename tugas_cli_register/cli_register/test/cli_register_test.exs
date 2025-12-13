defmodule CliRegisterTest do
  use ExUnit.Case
  doctest CliRegister

  test "greets the world" do
    assert CliRegister.hello() == :world
  end
end
