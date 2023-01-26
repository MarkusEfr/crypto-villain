defmodule CryptoVillainWeb.Api.PostController do
  use CryptoVillainWeb, :controller

  alias CryptoVillain.Posts
  alias CryptoVillain.Posts.Post

  action_fallback CryptoVillainWeb.FallbackController

  def index(conn, params) do
    posts =
      case params["feed"] do
        "follows" -> Posts.list_posts(conn.assigns.current_user.id, :follows)
        "my_posts" -> Posts.list_posts(conn.assigns.current_user.id, :my_posts)
        _ -> Posts.list_posts(nil, "global")
      end

    render(conn, "index.json", posts: posts)
  end

  def create(conn, %{"post" => post_params}) do
    post_params = Map.put(post_params, "user_id", conn.assigns.current_user.id)

    with {:ok, %Post{} = post} <- Posts.create_post(post_params, [:user]) do
      conn
      |> put_status(:created)
      |> render("show.json", post: post)
    end
  end

  def show(conn, %{"id" => id}) do
    post = Posts.get_post!(id)
    render(conn, "show.json", post: post)
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    {user, post} = {conn.assigns.current_user, Posts.get_post!(id)}

    with :ok <- Bodyguard.permit(CryptoVillain.Posts, :edit, user, post),
         {:ok, %Post{} = post} <- Posts.update_post(post, post_params, [:user]) do
      render(conn, "show.json", post: post)
    end
  end

  def delete(conn, %{"id" => id}) do
    {user, post} = {conn.assigns.current_user, Posts.get_post!(id)}

    with :ok <- Bodyguard.permit(CryptoVillain.Posts, :edit, user, post),
         {:ok, %Post{}} <- Posts.delete_post(post) do
      send_resp(conn, :no_content, "")
    end
  end
end
