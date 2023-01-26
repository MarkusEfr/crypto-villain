defmodule CryptoVillainWeb.LiveHelpers do
  import Phoenix.Component

  alias CryptoVillain.Accounts
  alias CryptoVillain.Accounts.User

  def assign_defaults(session, socket) do
    socket =
      socket
      |> assign_new(:current_user, fn ->
        find_current_user(session)
      end)
      |> assign_feed()

    socket
  end

  defp find_current_user(session) do
    with user_token when not is_nil(user_token) <- session["user_token"],
         %User{} = user <- Accounts.get_user_by_session_token(user_token),
         do: user
  end

  defp assign_feed(socket) do
    socket =
      socket
      |> assign(:feed, "global")
  end

  def is_blank?(value) when is_bitstring(value), do: String.length(String.trim(value)) == 0

  def is_blank?(_value), do: false

  def error_to_string(:too_large), do: "Too large"

  def error_to_string(:too_many_files), do: "You have selected too many files"

  def error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end
