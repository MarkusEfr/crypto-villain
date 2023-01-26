defmodule CryptoVillainWeb.FollowLive.Index do
  use CryptoVillainWeb, :live_view

  alias CryptoVillain.Followings

  @impl true
  def mount(params, session, socket) do
    if user_exist?(params) do
      {:ok,
       session
       |> assign_defaults(socket)
       |> assign_page_title()
       |> assign_followings()}
    else
      socket = put_flash(socket, :error, "Please log in to see followings")
      {:ok, redirect(socket, to: "/")}
    end
  end

  @impl true
  def handle_info({:updated_follow, _follow}, socket) do
    {:noreply, assign_followings(socket)}
  end

  @impl true
  def handle_event("delete", follow_params, socket) do
    follow =
      cond do
        Map.has_key?(follow_params, "id") ->
          Followings.get_follow!(follow_params["id"])

        Map.has_key?(follow_params, "user_id") and Map.has_key?(follow_params, "follow_user_id") ->
          Followings.get_follow!(follow_params["user_id"], follow_params["follow_user_id"])
      end

    with :ok <-
           Bodyguard.permit(
             CryptoVillain.Followings,
             :delete,
             socket.assigns.current_user,
             follow
           ),
         {:ok, follow} <- Followings.delete_follow(follow) do
      {:noreply, assign_followings(socket)}
    end
  end

  defp assign_followings(socket) do
    socket =
      socket
      |> assign(:follows, Followings.list_followings(socket.assigns.current_user.id, :to))
      |> assign(:subscribers, Followings.list_followings(socket.assigns.current_user.id, :from))
  end

  defp user_exist?(params) do
    String.length(String.trim(params["current_user"])) > 0
  end

  defp assign_page_title(socket) do
    socket |> assign(:page_title, "Followings")
  end
end
