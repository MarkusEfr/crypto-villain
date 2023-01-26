defmodule CryptoVillainWeb.Api.FollowView do
  use CryptoVillainWeb, :view
  alias CryptoVillainWeb.Api.FollowView

  def render("index.json", %{followings: followings}) do
    %{data: render_many(followings, FollowView, "show.json")}
  end

  def render("index.json", %{follow: follow}) do
    %{data: render_one(follow, FollowView, "show.json")}
  end

  def render("show.json", %{follow: follow}) do
    %{
      id: follow.id,
      user_id: follow.user_id,
      email: follow.email
    }
  end

  def render("error.json", %{error: error}) do
    %{error: error}
  end
end
