defmodule RemoteCheckoutTest do
  use ExUnit.Case
  doctest RemoteCheckout
  alias RemoteCheckout, as: RC
  alias TreeStorage, as: TS
  @expand :expand

  @root [
 %{"name" => "LICENSE", "oid" => "82e", "type" => "blob"},
 %{"name" => "README.md", "oid" => "f48", "type" => "blob"},
 %{"name" => "lib", "oid" => "3b8", "type" => "tree"},
 %{"name" => "test", "oid" => "0f5", "type" => "tree"}]

  test "to_tree" do
    assert [%{"name" => "LICENSE", "oid" => "82e", "type" => "blob"},
            %{"name" => "lib", "oid" => "3b8", "type" => "tree"}]
            |> RC.to_tree() == 
    [TS.leaf("LICENSE", "82e"), TS.tree("lib", [TS.leaf(@expand, "3b8")])]
  end

  test "find and get" do
    root = RC.to_tree(@root)
    assert RC.find_expand(root) == ["lib"]
    assert RC.get_expand(root, ["lib"]) == "3b8"
  end
end
