defmodule CryptoVillain.FollowingsTest do
  use CryptoVillain.DataCase

  alias CryptoVillain.Followings
  alias CryptoVillain.Followings.Follow
  alias CryptoVillain.Factory

  describe "followings" do
    setup do
      %{follow: Factory.insert(:follow)}
    end

    @invalid_attrs %{user_id: nil}

    test "list_followings/0 returns all followings", %{follow: follow} do
      assert Followings.list_followings() == [follow]
    end

    test "get_follow!/1 returns the follow with given id", %{follow: follow} do
      assert Followings.get_follow!(follow.id) == follow
    end

    test "create_follow/1 with valid data creates a follow" do
      valid_attrs = %{
        user_id: Factory.build(:user).id,
        follow_user_id: Factory.build(:user).id
      }

      assert {:ok, %Follow{} = follow} = Followings.create_follow(valid_attrs)
    end

    test "create_follow/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Followings.create_follow(@invalid_attrs)
    end

    test "delete_follow/1 deletes the follow", %{follow: follow} do
      assert {:ok, %Follow{}} = Followings.delete_follow(follow)
      assert_raise Ecto.NoResultsError, fn -> Followings.get_follow!(follow.id) end
    end
  end
end
