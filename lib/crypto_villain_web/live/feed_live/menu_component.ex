defmodule CryptoVillainWeb.MenuComponent do
  use Phoenix.Component

  attr :feed, :string, required: true
  attr :current_user, :atom, required: true

  def render(assigns) do
    ~H"""
      <div class="row gx-5 py-2">
      <div class="col-md-10 ps-5 pt-3">
        <div class={"#{if @feed=="global" do "theme-bg" else "bg-dark" end} badge text-wrap feed-menu-item"} phx-click="show_feed" phx-value-feed={:global} phx-value-user_id={@current_user.id}>
          Global feed
        </div>
        <div class={"#{if @feed=="my_posts" do "theme-bg" else "bg-dark" end} badge text-wrap feed-menu-item"} phx-click="show_feed" phx-value-feed={:my_posts} phx-value-user_id={@current_user.id}>
          My posts
        </div>
        <div class={"#{if @feed=="follows" do "theme-bg" else "bg-dark" end} badge text-wrap feed-menu-item"} phx-click="show_feed" phx-value-feed={:follows} phx-value-user_id={@current_user.id}>
          Follows
        </div>
      </div>
    </div>
    """
  end
end
