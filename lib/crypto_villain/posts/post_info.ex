defmodule CryptoVillain.Posts.PostInfo do
  @enforce_keys [:id, :user_id, :author, :content, :inserted_at]
  defstruct [:id, :user_id, :author, :content, :image, :inserted_at, subscription: nil]
end
