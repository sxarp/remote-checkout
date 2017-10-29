defmodule TreeStorageTest do
  use ExUnit.Case
  doctest TreeStorage

  test "find when head is not list" do
    con = fn {_, _, data} -> data == :ok end
    assert TreeStorage.find([], con) == nil
    assert TreeStorage.find([{:name, :meta, :ok}], con) == [{:name, :meta}]
    assert TreeStorage.find([{:name, :meta, :ok}, {nil, nil, nil}], con) == [{:name, :meta}]
    assert TreeStorage.find([{nil, nil, nil}, {:name, :meta, :ok}], con) == [{:name, :meta}]
  end
  test "find when head is list" do
    con = fn {_, _, data} -> data == :ok end
    assert TreeStorage.find([{:name1, :meta1, [{:name, :meta, :ok}]}], con) == [{:name1, :meta1}, {:name, :meta}]
    assert TreeStorage.find([{:name1, :meta1, [{nil, nil, nil}, {:name, :meta, :ok}]}], con) == [{:name1, :meta1}, {:name, :meta}]
    assert TreeStorage.find([{:name1, :meta1, [{nil, nil, nil}, {:name, :meta, nil}]}], con) == nil
  end
  test "find general" do
    con = fn {_, _, data} -> data == :ok end
    assert TreeStorage.find([{:name1, :meta1, [{nil, nil, nil}, {:name, :mata, []}]}, {:name, :meta, :ok}], con) == [{:name, :meta}]
  end

  test "get" do
    assert TreeStorage.get([{:name, :meta, :ok}], [:name]) == {:name, :meta, :ok}
    assert TreeStorage.get([{:name1, :meta1, [{nil, nil, nil}, {:name, :meta, :ok}]}], [:name1, :name]) == {:name, :meta, :ok}
  end

  test "replace" do
    replaced_leaf = {:name, :meta, :data}
    new_leaf = {:name, :new_meta, :new_data}
    assert TreeStorage.replace([replaced_leaf], [:name], new_leaf) == [new_leaf]
    random_leafs = for n <- 1..20, do: {n, n, n}
    assert TreeStorage.replace(random_leafs ++ [replaced_leaf|random_leafs], [:name], new_leaf) == random_leafs ++ [new_leaf|random_leafs]

    assert TreeStorage.replace(random_leafs ++ [{:parent, nil, [replaced_leaf]}|random_leafs], [:parent, :name], new_leaf) == random_leafs ++ [{:parent, nil, [new_leaf]}|random_leafs]
  end

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
