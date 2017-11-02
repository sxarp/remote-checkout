defmodule FetchGithubTest do
  use ExUnit.Case
  doctest FetchGithub

  test "query_for_tree" do
    owner = "sxarp"
    repo_name = "remote_checkout"
    oid = '114514'

    lhs = """
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
    |> FetchGithub.to_json |> String.replace(" ", "")

    rhs = FetchGithub.query_for_tree(oid, owner, repo_name)
          |> FetchGithub.to_json |> String.replace(" ", "")

    assert lhs == rhs
  end

  test "query_for_branch" do
    owner = "sxarp"
    repo_name = "remote_checkout"
    branch_name = "master"

    lhs ="""
    query{
    repository(owner: "#{owner}", name: "#{repo_name}"){
    ref(qualifiedName: "#{branch_name}"){
    target{
    ... on Commit{
    tree{
    oid }}}}}}
    """
    |> FetchGithub.to_json |> String.replace(" ", "")

    rhs = FetchGithub.query_for_branch(owner, repo_name, branch_name)
          |> FetchGithub.to_json |> String.replace(" ", "")

    assert lhs == rhs
  end

  test "header" do
    token = "token"
    assert FetchGithub.header(token) ==  [Authorization: "Bearer #{token}", Accept: "Application/json; Charset=utf-8"]
  end

  test "parse_json" do
    body = "body"
    assert body == FetchGithub.parse_json({:ok, %{status_code: 200, body: body |> Poison.encode! }})
  end

end
