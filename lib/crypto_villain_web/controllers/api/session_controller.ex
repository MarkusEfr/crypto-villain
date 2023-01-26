defmodule CryptoVillainWeb.Api.SessionController do
  use CryptoVillainWeb, :controller

  alias CryptoVillain.Accounts
  alias CryptoVillain.Accounts.User

  alias CryptoVillain.Guardian

  def create(conn, %{"email" => email, "password" => password} = params) do
    validation = [email: [presence: true], password: [presence: true]]

    with true <- Vex.valid?(Useful.atomize_map_keys(params), validation),
         %User{} = user <- Accounts.get_user_by_email_and_password(email, password) do
      {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user, %{})

      conn
      |> render("user.json", user: user, jwt: jwt)
    else
      _ ->
        conn
        |> put_status(401)
        |> render("error.json", %{error: "Wrong credentials"})
    end
  end
end
