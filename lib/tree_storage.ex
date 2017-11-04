defmodule TreeStorage do
  @moduledoc """
  Documentation for TreeStorage.
  """
  @doc """
  ## Manage tree-like structure.
  """

  @tree :tree
  @leaf :leaf

  def leaf(name, data), do: {@leaf, name, data}
  def tree(name, tree), do: check_tree(tree) && {@tree, name, tree}

  def find(tree, condition) when is_function(condition),
    do: check_tree(tree) && _find(tree, condition)
  defp _find([], _condition), do: nil
  defp _find([h|t], condition),
    do: _find(h, condition) || _find(t, condition)
  defp _find({@leaf, name, leaf}, condition),
    do: condition.(name, leaf) && [name]
  defp _find({@tree, name, tree}, condition),
    do: (path = _find(tree, condition)) && [name|path]

  def get(tree, path) when is_list(path),
    do: check_tree(tree) && _get(tree, path)
  defp _get(tree, []), do: tree
  defp _get([{_, name, tree}|t], [h_p|t_p]=path),
    do: (name == h_p && _get(tree, t_p)) || _get(t, path)

  def replace(tree, path, input) when is_list(path),
    do: check_tree(tree) && _replace(tree, path, input)
  defp _replace(_, [], input), do: input
  defp _replace([{type, name, data}|t], [name|path], input),
    do: [{type, name, _replace(data, path, input)}|t]
  defp _replace([h|t], path, input), do: [h|_replace(t, path, input)]

  def reduce(tree, leaf_fun, tree_fun, init)
    when is_function(leaf_fun) and is_function(tree_fun),
    do: check_tree(tree) && _reduce(tree, leaf_fun, tree_fun, init, init)
  defp _reduce([] ,_, _, _, acc), do: acc
  defp _reduce([{@tree, name, tree}|t], leaf_fun, tree_fun, init, acc),
    do: _reduce(t, leaf_fun, tree_fun, init,
    tree_fun.(acc, name, _reduce(tree, leaf_fun, tree_fun, init, init)))
  defp _reduce([{@leaf, name, leaf}|t], leaf_fun, tree_fun, init, acc),
    do: _reduce(t, leaf_fun, tree_fun, init, leaf_fun.(acc, name, leaf))

  def check_tree([]), do: true
  def check_tree([{@leaf, _, _}|t]), do: check_tree(t)
  def check_tree([{@tree, _, tree}|t]),
    do: check_tree(tree) && check_tree(t)
  def check_tree(tree),
    do: raise "Invalid tree structure: #{inspect tree}"
end
