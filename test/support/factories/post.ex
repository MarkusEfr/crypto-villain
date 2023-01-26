defmodule CryptoVillain.PostFactory do
  defmacro __using__(_opts) do
    quote do
      def post_factory do
        %CryptoVillain.Posts.Post{
          content: Faker.Lorem.sentence(2),
          user: fn -> build(:user) end
        }
      end
    end
  end
end
