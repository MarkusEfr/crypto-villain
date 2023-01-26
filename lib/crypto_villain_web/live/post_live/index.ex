defmodule CryptoVillainWeb.PostLive.Index do
  use CryptoVillainWeb, :live_view

  alias CryptoVillain.Posts
  alias CryptoVillain.Posts.Post
  alias CryptoVillainWeb.ModalComponent

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket), do: Posts.subscribe()
    socket = assign_defaults(session, socket)
    user_id = if socket.assigns[:current_user], do: socket.assigns.current_user.id

    {:ok, socket |> assign_feed_posts("global", %Flop{}, user_id)}
  end

  @impl true
  def handle_info({Posts, {:post, _action}, _post}, socket) do
    flop_pagination = %Flop{page: socket.assigns.meta.current_page || 1}
    {:noreply, socket |> assign_feed_posts(socket.assigns.feed, flop_pagination, socket.assigns.current_user.id)}
  end

  def handle_info({:updated_follow, _follow}, socket) do
    flop_pagination = %Flop{page: socket.assigns.meta.current_page || 1}
    {:noreply, socket |> assign_feed_posts(socket.assigns.feed, flop_pagination, socket.assigns.current_user.id)}
  end

  @impl true
  def handle_event("show_feed", params, socket) do
    user_id = if socket.assigns[:current_user], do: socket.assigns.current_user.id
    flop_pagination = %Flop{page: params["page"] || 1}

    socket =
      case params["feed"] do
        "global" ->
          socket
          |> assign_feed_posts("global", flop_pagination, user_id)

        "my_posts" ->
          socket
          |> assign_feed_posts(:my_posts, flop_pagination, user_id)

        "follows" ->
          socket
          |> assign_feed_posts(:follows, flop_pagination, user_id)
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    {user, post} = {socket.assigns.current_user, Posts.get_post!(id)}

    with :ok <- Bodyguard.permit(CryptoVillain.Posts, :delete, user, post),
         {:ok, _} <- Posts.delete_post(post) do
      flop_pagination = %Flop{page: socket.assigns.meta.current_page || 1}

      {:noreply, socket |> assign_feed_posts(socket.assigns.feed, flop_pagination, user.id)}
    else
      {:error, _reason} -> socket |> put_flash(:error, "You have no access to this post")

      {:noreply, socket}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    {user, post} = {socket.assigns.current_user, Posts.get_post!(id)}

    case Bodyguard.permit(CryptoVillain.Posts, :edit, user, post) do
      :ok ->
        socket
        |> assign(:page_title, "Edit Post")
        |> assign(:post, post)

      {:error, _reason} ->
        socket
        |> put_flash(:error, "You have no access to this post")
        |> push_redirect(to: "/")
    end
  end

  defp apply_action(socket, :new, _params) do
    if socket.assigns[:current_user] do
      socket
      |> assign(:page_title, "New Post")
      |> assign(:post, %Post{})
    else
      socket
      |> put_flash(:error, "Please log in to create a post")
      |> push_redirect(to: "/")
    end
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Posts")
    |> assign(:post, nil)
  end

  def can_manage?(user, post) do
    Bodyguard.permit(CryptoVillain.Posts, :can_manage, user, post) === :ok
  end

  defp assign_feed_posts(socket, feed, flop, user_id) do
    feed = if Kernel.is_atom(feed), do: Atom.to_string(feed), else: feed
    socket = socket |> assign(feed: feed)

    with {:ok, {posts, meta}} <- feed_posts(feed, flop, user_id) do
      socket
      |> assign(:posts, posts)
      |> assign(:meta, meta)
    end
  end

  defp feed_posts("global" = feed, flop, nil = _user_id) do
    with {:ok, {:ok, {posts, meta}}} <- Posts.list_posts(feed, flop, nil) do
      {:ok, {posts, meta}}
    end
  end

  defp feed_posts(feed, flop, user_id) do
    run_query = fn () ->
      case feed do
        "global" -> Posts.list_posts(:is_subscribe, flop, user_id)
        "my_posts" -> Posts.list_posts(:my_posts, flop, user_id)
        "follows" -> Posts.list_posts(:follows, flop, user_id)
      end
    end

    with {:ok, {:ok, {posts, meta}}} <- run_query.() do
      {:ok, {posts, meta}}
    end
  end
end
