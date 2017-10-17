defmodule TreeStorageTest do
  use ExUnit.Case
  doctest TreeStorage

  test "greets the world" do
    assert TreeStorage.hello() == :world
  end
  test "find when head is not list" do
    con = fn {_, _, data} -> data == :ok end
    assert TreeStorage.find([], con) == nil
    assert TreeStorage.find([{:name, :meta, :ok}], con) == {:ok, [{:name, :meta, :ok}]}
    assert TreeStorage.find([{:name, :meta, :ok}, {nil, nil, nil}], con) == {:ok, [{:name, :meta, :ok}]}
    assert TreeStorage.find([{nil, nil, nil}, {:name, :meta, :ok}], con) == {:ok, [{:name, :meta, :ok}]}
  end
  test "find when head is list" do
    con = fn {_, _, data} -> data == :ok end
    assert TreeStorage.find([{:name1, :meta1, [{:name, :meta, :ok}]}], con) == {:ok, [{:name1, :meta1}, {:name, :meta, :ok}]}
    assert TreeStorage.find([{:name1, :meta1, [{nil, nil, nil}, {:name, :meta, :ok}]}], con) == {:ok, [{:name1, :meta1}, {:name, :meta, :ok}]}
    assert TreeStorage.find([{:name1, :meta1, [{nil, nil, nil}, {:name, :meta, nil}]}], con) == nil
  end
  test "find general" do
    con = fn {_, _, data} -> data == :ok end
    assert TreeStorage.find([{:name1, :meta1, [{nil, nil, nil}, {:name, :meta, []}]}, {:name, :meta, :ok}], con) == {:ok, [{:name, :meta, :ok}]}
  end
end
