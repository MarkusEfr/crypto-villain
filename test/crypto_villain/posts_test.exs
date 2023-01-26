defmodule CryptoVillain.PostsTest do
  use CryptoVillain.DataCase

  alias CryptoVillain.Posts
  alias CryptoVillain.Factory

  describe "posts" do
    alias CryptoVillain.Posts.Post

    setup do
      %{post: Factory.insert(:post)}
    end

    @invalid_attrs %{content: nil}

    test "list_posts/0 returns all posts", %{post: post} do
      assert Posts.list_posts() == [post]
    end

    test "get_post!/1 returns the post with given id", %{post: post} do
      assert Posts.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      valid_attrs = %{content: "some content", user_id: Factory.build(:user).id}

      assert {:ok, %Post{} = post} = Posts.create_post(valid_attrs, [:user])
      assert post.content == "some content"
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Posts.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post", %{post: post} do
      update_attrs = %{content: "some updated content"}

      assert {:ok, %Post{} = post} = Posts.update_post(post, update_attrs, [:user])
      assert post.content == "some updated content"
    end

    test "update_post/2 with invalid data returns error changeset", %{post: post} do
      assert {:error, %Ecto.Changeset{}} = Posts.update_post(post, @invalid_attrs, [:user])
      assert post == Posts.get_post!(post.id)
    end

    test "delete_post/1 deletes the post", %{post: post} do
      assert {:ok, %Post{}} = Posts.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset", %{post: post} do
      assert %Ecto.Changeset{} = Posts.change_post(post)
    end
  end
end
