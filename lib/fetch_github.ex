defmodule FetchGithub do
  @moduledoc """
  Documentation for RemoteCheckout.
  """

  @doc """
  Fetch branch/tree/blob from GitHub.
  """

  def get_branch(branch_name, owner, repo_name, token),
    do: query_for_branch(owner, repo_name, branch_name)
    |> to_json |> graphql_request(token)
    |> parse_json |> parse_branch_response

  def get_tree(oid, owner, repo_name, token),
    do: query_for_tree(oid, owner, repo_name)
    |> to_json |> graphql_request(token)
    |> parse_json |> parse_tree_response

  def get_blob(oid, owner, repo_name, token),
    do: request_blob(oid, owner, repo_name, token)
    |> parse_json |> parse_blob_response

  def to_json(query), do: "{\"query\": \"#{
    query |> String.replace("\n", "") |> String.replace("\"", "\\\"")
    }\"}"

  def graphql_request(request_body, token),
    do: HTTPoison.post "https://api.github.com/graphql",
    request_body, header(token)

  def header(token), do: [Authorization: "Bearer #{token}",
    Accept: "Application/json; Charset=utf-8"]

  def parse_json({:ok, %{status_code: 200, body: body}}),
    do: body |> Poison.decode!

  def query_for_tree(oid, owner, repo_name), do: """
    query{
      repository(owner: "#{owner}", name: "#{repo_name}"){
        object(oid: "#{oid}"){
          __typename
          ... on Tree{
            entries{
              oid
              name
              type }}}}}
    """

  def parse_tree_response(%{"data" => %{"repository" => %{"object" =>
    %{"__typename" => "Tree", "entries" => entries}}}}), do: entries

  def query_for_branch(owner, repo_name, branch_name), do: """
    query{
      repository(owner: "#{owner}", name: "#{repo_name}"){
        ref(qualifiedName: "#{branch_name}"){
          target{
            ... on Commit{
              tree{
                oid }}}}}}
    """

  def parse_branch_response(%{"data" => %{"repository" => %{"ref" =>
    %{"target" => %{"tree" => %{"oid" => oid}}}}}}), do: oid

  def request_blob(oid, owner, repo_name, token),
    do: HTTPoison.get "https://api.github.com/repos/#{
      owner}/#{repo_name}/git/blobs/#{oid}", header(token)

  def parse_blob_response(%{"content" => content}),
    do: content |> String.replace("\n", "") |> Base.decode64!
end
