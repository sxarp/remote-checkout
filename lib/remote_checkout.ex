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

  def fetch_tree(binf=%{@branch_name => _, @owner => _,
    @repo_name => _, @token => _}, path \\ []),
    do: get_branch(binf) |> get_tree(binf)
    |> expand_tree(binf) |> TS.get(path)
    |> (fn t -> {export_tree(t), enumerate_files(t)} end).()

  def get_blobs(files, binf), do: files
    |> Enum.map(fn {_, oid} -> {oid, get_blob(oid, binf)} end)
    |> Map.new()

  def get_branch(%{@branch_name => bn, @owner => ow, @repo_name => rn,
    @token => to}), do: FG.get_branch(bn, ow, rn, to)

  def get_tree(oid, %{@owner => ow, @repo_name => rn, @token => to}),
    do: FG.get_tree(oid, ow, rn, to) |> to_tree()

  def get_blob(oid, %{@owner => ow, @repo_name => rn, @token => to}),
    do: FG.get_blob(oid, ow, rn, to)

  def expand_tree(tree, binf),
    do: find_expand(tree) |> (case do nil -> tree
      path -> grow_tree(tree, path, binf) |> expand_tree(binf) end)

  def grow_tree(tree, path, binf),
    do: tree |> get_expand(path) |> get_tree(binf) |> replace(tree, path)

  def to_tree(tree), do: tree
    |> Enum.map(fn
      %{"name" => name, "oid" => oid, "type" => "blob"} ->
        TS.leaf(name, oid)
      %{"name" => name, "oid" => oid, "type" => "tree"} ->
        TS.tree(name, [TS.leaf(@expand, oid)])
    end)

  def replace(input, tree, path), do: TS.replace(tree, path, input)

  def find_expand(tree),
    do: TS.find(tree, fn @expand, _oid -> true
      _name, _oid -> false end)
    |> (case do nil -> nil path -> path |> Enum.reverse() |>
        (fn [@expand|p] -> p end).() |> Enum.reverse() end)

  def get_expand(tree, path), do: TS.get(tree, path ++ [@expand])

  def export_tree(tree), do: TS.reduce(tree,
                fn acc, name, oid -> [{name, oid}|acc] end,
                fn acc, name, tree -> [{name, tree}|acc] end, [])

  def enumerate_files(tree), do: TS.reduce(tree,
                fn acc, name, oid -> [{name, oid}|acc] end,
                fn acc, _, oids -> oids ++ acc end, [])
end
