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

  def get([{name, _, _} = leaf|_], [name]), do: leaf
  def get([{path_h, _, index}|_], [path_h|path_t]), do: get(index, path_t)
  def get([_|t], path), do: get(t, path)

  def replace([{name, _, _}|tree_t], [name], input), do: [input|tree_t]
  def replace([{name, meta, index}|tree_t], [name|path_t], input),
    do: [{name, meta, replace(index, path_t, input)}|tree_t]
  def replace([tree_h|tree_t], path, input), do: [tree_h|replace(tree_t, path, input)]

  def reduce(tree, leaf_fun, tree_fun, init),
    do: reduce_inp(tree, leaf_fun, tree_fun, init, init)

  defp reduce_inp([] ,_, _, _, acc), do: acc
  defp reduce_inp([{name, meta, tree}=h|t], leaf_fun, tree_fun,
    init, acc) when is_list(tree) do
    reduced_tree = reduce_inp(tree, leaf_fun, tree_fun, init, init)
    new_acc = tree_fun.({name, meta, reduced_tree}, acc)
    reduce_inp(t, leaf_fun, tree_fun, init, new_acc)
  end
  defp reduce_inp([h|t], leaf_fun, tree_fun, init, acc),
    do: reduce_inp(t, leaf_fun, tree_fun, init, leaf_fun.(h, acc))
end
