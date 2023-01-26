defmodule CryptoVillainWeb.Api.FollowControllerTest do
  use CryptoVillainWeb.ConnCase

  alias CryptoVillain.Factory

  @invalid_attrs %{
    user_id: nil,
    follow_user_id: -1
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:create_user_and_assign_valid_jwt]

    test "lists all followings", %{conn: conn} do
      conn = get(conn, Routes.api_follow_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create follow" do
    setup [:create_user_and_assign_valid_jwt]

    test "renders follow when data is valid", %{conn: conn, user: user} do
      attrs = Factory.params_for(:follow, user_id: user.id)

      conn = post(conn, Routes.api_follow_path(conn, :create), follow: attrs)
      assert json_response(conn, 201)["id"] != nil
    end

    test "renders errors when data is invalid", %{conn: conn} do
      assert_raise Ecto.ConstraintError,
                   ~r/constraint error when attempting to insert/,
                   fn ->
                     post(conn, Routes.api_follow_path(conn, :create), follow: @invalid_attrs)
                   end
    end
  end

  describe "delete follow" do
    setup [:create_user_and_assign_valid_jwt]

    test "deletes chosen follow", %{conn: conn, user: user} do
      attrs = %{user_id: user.id}
      follow = Factory.insert(:follow, attrs)

      conn = delete(conn, Routes.api_follow_path(conn, :delete, follow))
      assert response(conn, 204)
    end
  end
end
