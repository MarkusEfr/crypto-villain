defmodule CryptoVillainWeb.PostControllerTest do
  use CryptoVillainWeb.ConnCase

  alias CryptoVillain.Factory

  @update_attrs %{
    content: Faker.Lorem.sentence(2)
  }
  @invalid_attrs %{
    content: nil
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:create_user_and_assign_valid_jwt]

    test "lists all posts", %{conn: conn} do
      conn = get(conn, Routes.api_post_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create post" do
    setup [:create_user_and_assign_valid_jwt]

    test "renders post when data is valid", %{conn: conn, user: user} do
      attrs = Factory.params_for(:post, user: user)

      conn = post(conn, Routes.api_post_path(conn, :create), post: attrs)
      assert json_response(conn, 201)["data"]["content"] == attrs.content
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.api_post_path(conn, :create), post: @invalid_attrs)
      assert json_response(conn, 404)["errors"] != %{}
    end
  end

  describe "update post" do
    setup [:create_user_and_assign_valid_jwt]

    test "renders post when data is valid", %{conn: conn, user: user} do
      post = Factory.insert(:post, %{user: user})

      conn = put(conn, Routes.api_post_path(conn, :update, post), post: @update_attrs)
      assert json_response(conn, 200)["data"]["id"] == post.id
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      post = Factory.insert(:post, user: user)

      conn = put(conn, Routes.api_post_path(conn, :update, post), post: @invalid_attrs)
      assert json_response(conn, 404)["errors"] != %{}
    end
  end

  describe "delete post" do
    setup [:create_user_and_assign_valid_jwt]

    test "deletes chosen post", %{conn: conn, user: user} do
      post = Factory.insert(:post, user: user)

      conn = delete(conn, Routes.api_post_path(conn, :delete, post))
      assert response(conn, 204)
    end
  end
end
