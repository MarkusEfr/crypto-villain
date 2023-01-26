defmodule CryptoVillainWeb.Policy.Post do
  @behaviour Bodyguard.Policy

  alias CryptoVillain.Accounts.User
  alias CryptoVillain.Posts.Post
  alias CryptoVillain.Posts.PostInfo

  # Users can modify their own posts
  def authorize(action, %User{id: user_id}, %Post{user_id: user_id})
    when action in [:edit, :delete, :can_manage], do: :ok

  # Accept authorize within post info struct
  def authorize(action, %User{id: user_id}, %PostInfo{user_id: user_id})
    when action in [:edit, :delete, :can_manage], do: :ok

  # Catch-all: deny everything else
  def authorize(_action, _user, _params), do: {:error, :forbidden}
end
