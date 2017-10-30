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
    new_leaf = TS.leaf(:name, :new_data)
    old_tree = [old_leaf]
    new_tree = [new_leaf]
    assert TS.replace(old_tree, [:name], :new_data) == new_tree

    leafs = for n <- 1..20, do: TS.leaf(n, n)
    old_tree = leafs ++ [TS.tree(:parent, leafs ++ [old_leaf] ++ leafs)] ++ leafs
    new_tree = leafs ++ [TS.tree(:parent, leafs ++ [new_leaf] ++ leafs)] ++ leafs
    assert TS.replace(old_tree, [:parent, :name], :new_data) == new_tree
  end

  test "reduce" do
    tree = for n <- 1..4, do: TS.leaf(n, n)
    leaf_fun = fn acc, _, x -> x + acc end
    tree_fun = leaf_fun
    assert 10 == TS.reduce(tree, leaf_fun, tree_fun, 0)
    new_tree = tree ++ [TS.tree(:name, tree)] ++ tree
    assert 30 == TS.reduce(new_tree, leaf_fun, tree_fun, 0)
  end
end
