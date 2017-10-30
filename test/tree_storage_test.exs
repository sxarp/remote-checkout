defmodule TreeStorageTest do
  use ExUnit.Case
  doctest TreeStorage
  alias TreeStorage, as: TS

  @tree :tree
  @leaf :leaf

  test "Basic test for find" do
    con = fn data -> data == :ok end
    assert TS.find([{@leaf, :name, :ok}], con) == [:name]
    assert TS.find([{@leaf, nil, nil}, {@leaf, :name, :ok}], con) == [:name]
  end

  test "find when head is list" do
    con = fn data -> data == :ok end
    assert TS.find([{@tree, :parent, [{@leaf, :name, :ok}]}], con) == [:parent, :name]
    assert TS.find([{@leaf, nil, nil}, {@tree, :parent, [{@leaf, nil, nil}, {@leaf, :name, :ok}]}], con) == [:parent, :name]
    assert TS.find([{@leaf, nil, nil}, {@tree, :parent, [{@leaf, nil, nil}, {@leaf, :name, :no}]}], con) == nil
  end

  test "get" do
    assert TS.get([{@leaf, nil, nil}, {@leaf, :name, :data}], [:name]) == :data
    assert TS.get([{@tree, :parent, [{@leaf, nil, nil}, {@leaf, :name, :data}]}], [:parent, :name]) == :data
  end

  test "replace" do
    old_leaf = TS.leaf(:name, :data)
    new_leaf = TS.leaf(:new_name, :new_data)
    old_tree = [old_leaf]
    new_tree = [new_leaf]
    assert TS.replace(old_tree, [:name], new_leaf) == new_tree

    leafs = for n <- 1..20, do: TS.leaf(n, n)
    IO.inspect leafs
    old_tree = leafs ++ [TS.tree(:parent, leafs ++ [old_leaf] ++ leafs)] ++ leafs
    new_tree = leafs ++ [TS.tree(:parent, leafs ++ [new_leaf] ++ leafs)] ++ leafs
    assert TS.replace(old_tree, [:parent, :name], new_leaf) == new_tree

    #assert TS.replace(random_leafs ++ [{:parent, nil, [replaced_leaf]}|random_leafs], [:parent, :name], new_leaf) == random_leafs ++ [{:parent, nil, [new_leaf]}|random_leafs]
  end

  @tag :skip
  test "reduce" do
    tree = [{:name, :_meta, 1}, {:name, :_meta, 1}]
    assert 2 == TS.reduce(tree,
      fn {_, _, x}, enum -> x + enum end,
      fn {_, _, x}, enum -> x + enum end,
      0)
    tree = tree ++ [{:name, :_meta, tree}] ++ tree
    assert 6 == TS.reduce(tree,
      fn {_, _, x}, enum -> x + enum end,
      fn {_, _, x}, enum -> x + enum end,
      0)
    assert [1, 1, 1, 1, 1, 1] == TS.reduce(tree,
      fn {_, _, x}, enum -> [x] ++ enum end,
      fn {_, _, x}, enum -> x ++ enum end,
      [])
  end
end
