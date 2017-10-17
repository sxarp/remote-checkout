defmodule TreeStorage do
  @moduledoc """
  Documentation for TreeStorage.
  """

  @doc """
  Hello world.

  ## Examples

  iex> RemoteCheckout.hello
  :world

  """
  def hello do
    :world
  end

  def find([{name, meta, list} | t], condition) when is_list(list) do
    case find(list, condition) do
      {:ok, ret_val} -> {:ok, [{name, meta} | ret_val]}
      nil -> find(t, condition)
    end
  end
  def find([h | t], condition), do: if condition.(h), do: {:ok, [h]}, else: find(t, condition)
  def find([], condition), do: nil
end
