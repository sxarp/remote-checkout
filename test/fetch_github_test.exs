defmodule FetchGithubTest do
  use ExUnit.Case
  doctest FetchGithub

  test "greets the world" do
    assert FetchGithub.hello() == :world
  end
end
