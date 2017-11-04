defmodule RemoteCheckout do
  alias TreeStorage, as: TS
  alias FetchGithub, as: FG
  @moduledoc """
  Documentation for RemoteCheckout.
  """
  @doc """
  Hello world.
  """

  @expand :expand
  @branch_name :branch_name
  @owner :owner
  @repo_name :repo_name
  @token :token

  def create_branch_info(binf=%{@branch_name => _, @owner => _,
    @repo_name => _, @token => _}), do: binf

  def get_branch(%{@branch_name => bn, @owner => ow, @repo_name => rn,
    @token => to}), do: FG.get_branch(bn, ow, rn, to)

  def get_tree(oid, %{@owner => ow, @repo_name => rn, @token => to}),
    do: FG.get_tree(oid, ow, rn, to) |> to_tree()

  def get_blob(oid, %{@owner => ow, @repo_name => rn, @token => to}),
    do: FG.get_blob(oid, ow, rn, to)

  def expand_tree(tree, bf),
    do: (case find_expand(tree) do
      nil -> tree
      path -> grow_tree(tree, path, bf) |> expand_tree(bf) end)

  def grow_tree(tree, path, bf),
    do: tree |> get_expand(path) |> get_tree(bf) |> replace(tree, path)

  def to_tree_element(%{"name" => name, "oid" => oid, "type" => type}),
    do: (case type do
      "blob" -> TS.leaf(name, oid)
      "tree" -> TS.tree(name, [TS.leaf(@expand, oid)]) end)

  def to_tree(tree), do: tree |> Enum.map(&to_tree_element/1)
  
  def replace(input, tree, path), do: TS.replace(tree, path, input)

  def find_expand(tree), do: find_expand_raw(tree) |> manage_path()

  def find_expand_raw(tree),
    do: TS.find(tree, fn @expand, _oid -> true
                           _name, _oid -> false end)

  def manage_path(nil), do: nil
  def manage_path(path), do: path |> Enum.reverse()
    |> (fn [@expand|p] -> p end).() |> Enum.reverse()
  
  def get_expand(tree, path), do: TS.get(tree, path ++ [@expand])
end
