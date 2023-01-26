defmodule CryptoVillainWeb.Api.FollowController do
  use CryptoVillainWeb, :controller

  alias CryptoVillain.Followings
  alias CryptoVillain.Followings.Follow

  action_fallback CryptoVillainWeb.FallbackController

  def index(conn, params) do
    followings =
      case params["direction"] do
        "from" -> Followings.list_followings(conn.assigns.current_user.id, :from)
        _ -> Followings.list_followings(conn.assigns.current_user.id, :to)
      end

    render(conn, "index.json", followings: followings)
  end

  def create(conn, %{"follow" => follow_params}) do
    follow_params = Map.put(follow_params, "user_id", conn.assigns.current_user.id)

    with {:ok, %{} = follow} <- Followings.create_follow(follow_params) do
      conn
      |> put_status(:created)
      |> render("show.json", follow: follow)
    end
  end

  def delete(conn, %{"id" => id}) do
    {user, follow} = {conn.assigns.current_user, Followings.get_follow!(id)}

    with :ok <- Bodyguard.permit(CryptoVillain.Followings, :delete, user, follow),
         {:ok, %Follow{}} <- Followings.delete_follow(follow) do
      send_resp(conn, :no_content, "")
    end
  end
end
