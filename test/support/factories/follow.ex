defmodule CryptoVillain.FollowFactory do
  defmacro __using__(_opts) do
    quote do
      def follow_factory do
        %CryptoVillain.Followings.Follow{
          user_id: fn -> build(:user).id end,
          follow_user_id: build(:user).id
        }
      end
    end
  end
end
