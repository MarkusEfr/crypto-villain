defmodule CryptoVillain.Followings.FollowInfo do
  @enforce_keys [:id, :user_id, :email]
  defstruct [:id, :user_id, :email, subscription: nil]
end
