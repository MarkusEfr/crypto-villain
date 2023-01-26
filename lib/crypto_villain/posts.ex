defmodule CryptoVillain.Posts do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false
  alias CryptoVillain.Repo

  alias CryptoVillain.Posts.Post
  alias CryptoVillain.Accounts.User
  alias CryptoVillain.Followings.Follow
  alias CryptoVillain.Posts.PostInfo

  defdelegate authorize(action, user, params), to: CryptoVillainWeb.Policy.Post

  @topic inspect(__MODULE__)

  def subscribe do
    Phoenix.PubSub.subscribe(CryptoVillain.PubSub, @topic)
  end

  defp broadcast_change({:ok, result}, event) do
    Phoenix.PubSub.broadcast(CryptoVillain.PubSub, @topic, {__MODULE__, event, result})
    {:ok, result}
  end

  defp broadcast_change({:error, changeset}, _event), do: {:error, changeset}

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """

  def list_posts("global", flop, nil = user_id) do
    query = from p in Post, join: u in User, on: u.id == p.user_id, order_by: [desc: :inserted_at]

    query
    |> struct_select()
    |> Flop.validate_and_run(flop)
  end

  def list_posts(:is_subscribe, flop  \\ %Flop{}, user_id) do
    query = from p in Post, join: u in User, on: u.id == p.user_id, order_by: [desc: :inserted_at]

    query
    |> with_follow_struct(user_id)
    |> struct_select()
    |> Flop.validate_and_run(flop)
  end

  def list_posts(:my_posts, flop, user_id) do
    query =
      from p in Post,
        join: u in User,
        on: p.user_id == u.id,
        where: u.id == ^user_id,
        order_by: [desc: :inserted_at]

    query
    |> struct_select()
    |> Flop.validate_and_run(flop)
  end

  def list_posts(:follows, flop, user_id) do
    query =
      from p in Post,
        join: u in User,
        on: u.id == p.user_id,
        join: f in Follow,
        as: :follow,
        on: f.follow_user_id == u.id,
        where: f.user_id == ^user_id,
        order_by: [desc: :inserted_at]

    query
    |> struct_select()
    |> Flop.validate_and_run(flop)
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id), do: Repo.get!(Post, id)

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def create_post(post_params, preload) do
    with changeset <- Post.changeset(%Post{}, post_params),
         {:ok, %Post{} = post} <- Repo.insert(changeset),
         {:ok, _result} <- broadcast_change({:ok, post}, {:post, :created}) do
      {:ok, Repo.preload(post, preload)}
    end
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs, preload) do
    with changeset <- Post.changeset(post, attrs),
         {:ok, %Post{} = post} <- Repo.update(changeset),
         {:ok, _result} <- broadcast_change({:ok, post}, {:post, :updated}) do
      {:ok, Repo.preload(post, preload)}
    end
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    post
    |> Repo.delete()
    |> broadcast_change({:post, :deleted})
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  defp with_follow_struct(query, user_id) do
    from [p, u] in query,
      left_join: f1 in Follow,
      as: :follow,
      on: f1.user_id == ^user_id and f1.follow_user_id == p.user_id
  end

  defp struct_select(query) do
    if has_named_binding?(query, :follow) do
      from [p, u, f] in query,
        select: %PostInfo{
          id: p.id,
          user_id: p.user_id,
          author: u.email,
          content: p.content,
          image: p.image,
          inserted_at: p.inserted_at,
          subscription: f.id
        }
    else
      from [p, u] in query,
        select: %PostInfo{
          id: p.id,
          user_id: p.user_id,
          author: u.email,
          content: p.content,
          image: p.image,
          inserted_at: p.inserted_at,
          subscription: nil
        }
    end
  end
end
