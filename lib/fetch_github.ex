defmodule FetchGithub do
  @moduledoc """
  Documentation for RemoteCheckout.
  """

  @doc """
  Hello world.

  ## Examples

      iex> RemoteCheckout.hello
      :world

  """
  def get_tree(oid, owner, repo_name, token) do
    query_for_tree(oid, owner, repo_name)
    |> https_request(token)
    |> to_json
    |> parse_tree_response
  end

  def get_branch(branch_name, owner, repo_name, token) do
    query_for_branch(owner, repo_name, branch_name)
    |> https_request(token)
    |> to_json
    |> parse_branch_response
  end

  def get_blob(hash, owner, repo_name, token) do
    #todo
  end

  def to_json({:ok, %{body: body}}), do: body |> Poison.decode!

  def https_request(query, token) do
    url = "https://api.github.com/graphql"
    headers = [Authorization: "Bearer #{token}",
               Accept: "Application/json; Charset=utf-8"]
    rectified_query = query
                      |> String.replace("\n", "")
                      |> String.replace("\"", "\\\"")
                      |> (&("{\"query\": \"#{&1}\"}")).()
    HTTPoison.post url, rectified_query, headers
  end

  def query_for_tree(oid, owner, repo_name) do
    """
    query{
      repository(owner: "#{owner}", name: "#{repo_name}"){
        object(oid: "#{oid}"){
          __typename
          ... on Tree{
            entries{
              oid
              name
              type
            }
          }
        }
      }
    }
    """
  end

  def parse_tree_response(%{"data" => %{"repository" => %{"object" => 
    %{"__typename" => "Tree", "entries" => entries}}}}), do: entries

  def query_for_branch(owner, repo_name, branch_name) do
    """
    query{
      repository(owner: "#{owner}", name: "#{repo_name}"){
        ref(qualifiedName: "#{branch_name}"){
          target{
            ... on Commit{
              tree{
                oid
              }
            }
          }
        }
      }
    }
    """
  end

  def parse_branch_response(%{"data" => %{"repository" => %{"ref" => 
    %{"target" => %{"tree" => %{"oid" => oid}}}}}}), do: oid
end
