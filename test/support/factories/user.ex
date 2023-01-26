defmodule CryptoVillain.UserFactory do
  defmacro __using__(_opts) do
    quote do
      def valid_user_password, do: "aX12$43Qri9!"

      def user_factory(attrs \\ %{}) do
        {:ok, user} =
          attrs
          |> valid_user_attributes()
          |> CryptoVillain.Accounts.register_user()

        user
      end

      def valid_user_attributes(attrs \\ %{}) do
        Enum.into(attrs, %{
          email: Faker.Internet.email(),
          password: valid_user_password()
        })
      end

      def extract_user_token(fun) do
        {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
        [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
        token
      end
    end
  end
end
