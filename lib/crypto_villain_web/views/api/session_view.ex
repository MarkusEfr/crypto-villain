defmodule CryptoVillainWeb.Api.SessionView do
  use CryptoVillainWeb, :view

  def render("user.json", %{user: user, jwt: jwt}) do
    %{
      user: user,
      jwt: jwt
    }
  end

  def render("error.json", %{error: error}), do: %{error: error}
end
