defmodule CryptoVillainWeb.FollowLive.Subscription do
  use CryptoVillainWeb, :live_component

  alias CryptoVillain.Followings

  def handle_event("create", follow_params, socket) do
    case Followings.create_follow(follow_params) do
      {:ok, follow} ->
        send(self(), {:updated_follow, follow})
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("delete", follow_params, socket) do
    follow = Followings.get_follow!(follow_params["user_id"], follow_params["follow_user_id"])

    case Followings.delete_follow(follow) do
      {:ok, follow} ->
        send(self(), {:updated_follow, follow})

        {:noreply, socket}
    end
  end
end
