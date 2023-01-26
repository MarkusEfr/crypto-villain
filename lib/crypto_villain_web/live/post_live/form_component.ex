defmodule CryptoVillainWeb.PostLive.FormComponent do
  use CryptoVillainWeb, :live_component

  alias CryptoVillain.Posts

  @impl true
  def update(%{post: post} = assigns, socket) do
    changeset = Posts.change_post(post)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> allow_upload(:image, accept: ~w(.jpg .jpeg .png), max_entries: 1, auto_upload: true)}
  end

  @impl true
  def handle_event("validate", %{"post" => post_params}, socket) do
    post_params = put_user_id(post_params, socket)
    changeset =
      socket.assigns.post
      |> Posts.change_post(post_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"post" => post_params}, socket) do
    uploads =
      consume_uploaded_entries(socket, :image, fn %{path: path}, _entry ->
        dest = Path.join([:code.priv_dir(:crypto_villain), "static", "uploads", Path.basename(path)])

        File.cp!(path, dest)
        {:ok, Routes.static_path(socket, "/uploads/#{Path.basename(dest)}")}
      end)
    file = List.first(uploads, 1)
    post_params = if file == 1, do: post_params, else: Map.put(post_params, "image", file)

    save_post(socket, socket.assigns.action, put_user_id(post_params, socket))
  end

  defp save_post(socket, :edit, post_params) do
    case Posts.update_post(socket.assigns.post, post_params, [:user]) do
      {:ok, _post} ->
        {:noreply,
         socket
         |> put_flash(:info, "Post updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_post(socket, :new, post_params) do
    case Posts.create_post(post_params, [:user]) do
      {:ok, _post} ->
        {:noreply,
         socket
         |> put_flash(:info, "Post created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp put_user_id(post_params, socket), do: Map.put(post_params, "user_id", socket.assigns.current_user.id)
end
