defmodule FetchGithubTest do
  use ExUnit.Case
  doctest FetchGithub

  @owner "sxarp"
  @repo_name "remote_checkout"
  @oid "114514"
  @branch_name "master"
  @token "token"


  test "query_for_tree" do
    lhs = """
    query{
    repository(owner: "#{@owner}", name: "#{@repo_name}"){
    object(oid: "#{@oid}"){
    __typename
    ... on Tree{
    entries{
    oid
    name
    type }}}}}
    """
    |> FetchGithub.to_json |> String.replace(" ", "")

    rhs = FetchGithub.query_for_tree(@oid, @owner, @repo_name)
          |> FetchGithub.to_json |> String.replace(" ", "")

    assert lhs == rhs
  end

  test "query_for_branch" do
    lhs ="""
    query{
    repository(owner: "#{@owner}", name: "#{@repo_name}"){
    ref(qualifiedName: "#{@branch_name}"){
    target{
    ... on Commit{
    tree{
    oid }}}}}}
    """
    |> FetchGithub.to_json |> String.replace(" ", "")

    rhs = FetchGithub.query_for_branch(@owner, @repo_name, @branch_name)
          |> FetchGithub.to_json |> String.replace(" ", "")

    assert lhs == rhs
  end

  test "to_header" do
    assert FetchGithub.to_header(@token) ==  [Authorization: "Bearer #{@token}", Accept: "Application/json; Charset=utf-8"]
  end

  test "parse_json" do
    body = "body"
    assert body == FetchGithub.parse_json({:ok, %{status_code: 200, body: body |> Poison.encode! }})
  end

  test "url_for_blob" do
    assert FetchGithub.url_for_blob(@oid, @owner, @repo_name)
    == "https://api.github.com/repos/#{@owner}/#{
        @repo_name}/git/blobs/#{@oid}"
  end

  test "parse_blob_response" do
    assert "content" == FetchGithub.parse_blob_response(
      %{"content" => Base.encode64("content") <> "\n" })
  end

end
