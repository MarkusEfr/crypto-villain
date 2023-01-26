defmodule CryptoVillainWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use CryptoVillainWeb, :controller

  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(:forbidden)
    |> render("error.json", error: :forbidden)
  end

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render("error.json", error: :not_found)
  end

  def call(conn, {:error, message}) do
    conn
    |> put_status(:not_found)
    |> render("error.json", %{error: "#{inspect message.errors}"})
  end
end
