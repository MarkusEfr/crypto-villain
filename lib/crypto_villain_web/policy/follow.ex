defmodule CryptoVillainWeb.Policy.Follow do
  @behaviour Bodyguard.Policy

  alias CryptoVillain.Accounts.User
  alias CryptoVillain.Followings.Follow
  alias CryptoVillain.Followings.FollowInfo

  # Users can modify their own posts
  def authorize(action, %User{id: user_id}, %Follow{user_id: user_id})
    when action in [:edit, :delete], do: :ok

  # Accept authorize within follow info struct
  def authorize(action, %User{id: user_id}, %FollowInfo{user_id: user_id})
    when action in [:edit, :delete], do: :ok

  # Catch-all: deny everything else
  def authorize(_action, _user, _params), do: {:error, :forbidden}
end
