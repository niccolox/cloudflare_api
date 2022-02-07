defmodule CloudflareApiTest do
  use ExUnit.Case
  doctest CloudflareApi

  test "greets the world" do
    assert CloudflareApi.hello() == :world
  end
end
