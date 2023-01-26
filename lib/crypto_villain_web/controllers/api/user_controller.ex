defmodule CryptoVillainWeb.Api.UserController do
  use CryptoVillainWeb, :controller

  alias CryptoVillain.{Accounts, Avatar, Guardian}

  def update(conn, %{"image" => image} = params) do
    user = conn.assigns.current_user

    if image != nil do
      with upload <- base64_to_upload(image),
           {:ok, file} <- Avatar.store({upload, user}),
           {:ok, _updated_user} <- Accounts.update_user_avatar(user, %{avatar: upload}) do
        send_resp(conn, 200, "Image upload successful")
      else
        _ -> send_resp(conn, :service_unavailable, "Service unavailable")
      end
    else
      send_resp(conn, :bad_request, "Request not contain image")
    end
  end

  def base64_to_upload(str) do
    with {:ok, data} <- Base.decode64(str) do
      binary_to_upload(data)
    end
  end

  def binary_to_upload(binary) do
    with {:ok, path} <- Plug.Upload.random_file("upload"),
         {:ok, file} <- File.open(path, [:write, :binary]),
         :ok <- IO.binwrite(file, binary),
         :ok <- File.close(file) do
      %Plug.Upload{
        path: path,
        content_type: "image/png",
        filename: to_string(System.system_time(:second)) <> ".png"
      }
    end
  end
end
