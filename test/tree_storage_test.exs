defmodule TreeStorageTest do
  use ExUnit.Case
  doctest TreeStorage

  test "find when head is not list" do
    con = fn {_, _, data} -> data == :ok end
    assert TreeStorage.find([], con) == nil
    assert TreeStorage.find([{:name, :meta, :ok}], con) == [{:name, :meta, :ok}]
    assert TreeStorage.find([{:name, :meta, :ok}, {nil, nil, nil}], con) == [{:name, :meta, :ok}]
    assert TreeStorage.find([{nil, nil, nil}, {:name, :meta, :ok}], con) == [{:name, :meta, :ok}]
  end
  test "find when head is list" do
    con = fn {_, _, data} -> data == :ok end
    assert TreeStorage.find([{:name1, :meta1, [{:name, :meta, :ok}]}], con) == [{:name1, :meta1}, {:name, :meta, :ok}]
    assert TreeStorage.find([{:name1, :meta1, [{nil, nil, nil}, {:name, :meta, :ok}]}], con) == [{:name1, :meta1}, {:name, :meta, :ok}]
    assert TreeStorage.find([{:name1, :meta1, [{nil, nil, nil}, {:name, :meta, nil}]}], con) == nil
  end
  test "find general" do
    con = fn {_, _, data} -> data == :ok end
    assert TreeStorage.find([{:name1, :meta1, [{nil, nil, nil}, {:name, :meta, []}]}, {:name, :meta, :ok}], con) == [{:name, :meta, :ok}]
  end

  test 'replace' do
    replaced_node = {:name, :meta, :data}
    new_node = {:name, :new_meta, :new_data}
    assert TreeStorage.replace([replaced_node], [:name], new_node) == [new_node]
    random_nodes = for n <- 1..20, do: {n, n, n}
    assert TreeStorage.replace(random_nodes ++ [replaced_node|random_nodes], [:name], new_node) == random_nodes ++ [new_node|random_nodes]

    assert TreeStorage.replace(random_nodes ++ [{:parent, nil, [replaced_node]}|random_nodes], [:parent, :name], new_node) == random_nodes ++ [{:parent, nil, [new_node]}|random_nodes]
  end
end
