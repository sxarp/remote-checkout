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
    %{"data" => %{"repository" => %{"object" => %{"__typename" => "Tree",
    "entries" => entries}}}} 
    = query_for_tree(oid, owner, repo_name)
      |> https_request(token)
      |> to_json
    entries
  end

  def get_branch(branch_name, owner, repo_name, token) do
    %{"data" => %{"repository" => %{"ref" => 
      %{"target" => %{"tree" => %{"oid" => oid}}}}}}
    = query_for_branch(owner, repo_name, branch_name)
      |> https_request(token)
      |> to_json
    oid
  end

  def to_json({:ok, %{body: body}}), do: body |> Poison.decode!

  def get_blob(hash, owner, repo_name, token) do
    #todo
  end

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
end