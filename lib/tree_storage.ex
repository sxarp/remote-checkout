defmodule TreeStorage do
  @moduledoc """
  Documentation for TreeStorage.
  """
  @doc """
  ## Manage tree-like structure.
  """

  def find([], _), do: nil
  def find([tree_h|tree_t], condition),
    do: find(tree_h, condition) || find(tree_t, condition)
  def find({name, meta, index} = tree, condition) do
    cond do
      condition.(tree) -> [{name, meta}]
      is_list(index) and find(index, condition) != nil
        -> [{name, meta}|find(index, condition)]
      true -> nil
    end
  end

  def get([{name, _, _} = node|_], [name]), do: node
  def get([{path_h, _, index}|_], [path_h|path_t]), do: get(index, path_t)
  def get([_|t], path), do: get(t, path)

  def replace([{name, _, _}|tree_t], [name], input), do: [input|tree_t]
  def replace([{name, meta, index}|tree_t], [name|path_t], input),
    do: [{name, meta, replace(index, path_t, input)}|tree_t]
  def replace([tree_h|tree_t], path, input), do: [tree_h|replace(tree_t, path, input)]
end
