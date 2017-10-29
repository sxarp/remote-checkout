defmodule TreeStorageTest do
  use ExUnit.Case
  doctest TreeStorage
  alias TreeStorage, as: TS

  @tree :tree
  @leaf :leaf

  test "Basic test for find" do
    con = fn data -> data == :ok end
    assert TS.find([{@leaf, :name, :ok}], con) == [:name]
    assert TreeStorage.find([{@leaf, nil, nil}, {@leaf, :name, :ok}], con) == [:name]
  end

  test "find when head is list" do
    con = fn data -> data == :ok end
    assert TreeStorage.find([{@tree, :parent, [{@leaf, :name, :ok}]}], con) == [:parent, :name]
    assert TreeStorage.find([{@leaf, nil, nil}, {@tree, :parent, [{@leaf, nil, nil}, {@leaf, :name, :ok}]}], con) == [:parent, :name]
    assert TreeStorage.find([{@leaf, nil, nil}, {@tree, :parent, [{@leaf, nil, nil}, {@leaf, :name, :no}]}], con) == nil
  end

  test "get" do
    assert TreeStorage.get([{@leaf, nil, nil}, {@leaf, :name, :data}], [:name]) == :data
    assert TreeStorage.get([{@tree, :parent, [{@leaf, nil, nil}, {@leaf, :name, :data}]}], [:parent, :name]) == :data
  end

  @tag :skip
  test "replace" do
    replaced_leaf = {:name, :meta, :data}
    new_leaf = {:name, :new_meta, :new_data}
    assert TreeStorage.replace([replaced_leaf], [:name], new_leaf) == [new_leaf]
    random_leafs = for n <- 1..20, do: {n, n, n}
    assert TreeStorage.replace(random_leafs ++ [replaced_leaf|random_leafs], [:name], new_leaf) == random_leafs ++ [new_leaf|random_leafs]

    assert TreeStorage.replace(random_leafs ++ [{:parent, nil, [replaced_leaf]}|random_leafs], [:parent, :name], new_leaf) == random_leafs ++ [{:parent, nil, [new_leaf]}|random_leafs]
  end

  @tag :skip
  test "reduce" do
    tree = [{:name, :_meta, 1}, {:name, :_meta, 1}]
    assert 2 == TreeStorage.reduce(tree,
      fn {_, _, x}, enum -> x + enum end,
      fn {_, _, x}, enum -> x + enum end,
      0)
    tree = tree ++ [{:name, :_meta, tree}] ++ tree
    assert 6 == TreeStorage.reduce(tree,
      fn {_, _, x}, enum -> x + enum end,
      fn {_, _, x}, enum -> x + enum end,
      0)
    assert [1, 1, 1, 1, 1, 1] == TreeStorage.reduce(tree,
      fn {_, _, x}, enum -> [x] ++ enum end,
      fn {_, _, x}, enum -> x ++ enum end,
      [])
  end
end
