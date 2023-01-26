defmodule CryptoVillain.Followings do
  @moduledoc """
  The Followings context.
  """

  import Ecto.Query, warn: false
  alias CryptoVillain.Repo

  alias CryptoVillain.Followings.Follow
  alias CryptoVillain.Followings.FollowInfo
  alias CryptoVillain.Accounts.User

  defdelegate authorize(action, user, params), to: CryptoVillainWeb.Policy.Follow

  @doc """
  Returns the list of followings.

  ## Examples

      iex> list_followings(1, :to)
      [%Follow{}, ...]

  """

  def list_followings(user_id, direction) do
    join = join_direction(direction)
    where = where_direction(user_id, direction)

    query =
      from f in Follow,
        join: u in User,
        on: ^join,
        where: ^where

    query
    |> with_subscription({user_id, direction})
    |> struct_select()
    |> Repo.all()
  end

  defp with_subscription(query, {user_id, direction}) do
    reverse_subscription = from f1 in Follow, where: [user_id: ^user_id], select: [:id, :user_id, :follow_user_id]

    from [f, u] in query,
      left_join: f1 in subquery(reverse_subscription), as: :subscription, on: f1.follow_user_id == f.user_id
  end

  defp struct_select(query) do
    if has_named_binding?(query, :subscription) do
      from [f, u, f1] in query,
        select: %FollowInfo{id: f.id, user_id: u.id, email: u.email, subscription: f1.id}
    else
      from [f, u] in query,
        select: %FollowInfo{id: f.id, user_id: u.id, email: u.email, subscription: nil}
    end
  end

  @doc """
  Gets a single follow.

  Raises `Ecto.NoResultsError` if the Follow does not exist.

  ## Examples

      iex> get_follow!(123)
      %Follow{}

      iex> get_follow!(456)
      ** (Ecto.NoResultsError)

  """
  def get_follow!(id), do: Repo.get!(Follow, id)

  def get_follow!(user_id, follow_user_id) do
    follow =
      from f in Follow,
        where: [user_id: ^user_id, follow_user_id: ^follow_user_id]

    Repo.one!(follow)
  end

  @doc """
  Creates a follow.

  ## Examples

      iex> create_follow(%{field: value})
      {:ok, %Follow{}}

      iex> create_follow(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_follow(attrs \\ %{}) do
    {:ok, follow} =
      %Follow{}
      |> Follow.changeset(attrs)
      |> Repo.insert()

    {:ok, show_follow(follow)}
  end

  defp show_follow(follow) do
    query =
      from f in Follow,
        join: u in User,
        on: f.follow_user_id == u.id,
        where: f.id == ^follow.id,
        select: %{id: f.id, user_id: u.id, email: u.email}

    Repo.one!(query)
  end

  @doc """
  Deletes a follow.

  ## Examples

      iex> delete_follow(follow)
      {:ok, %Follow{}}

      iex> delete_follow(follow)
      {:error, %Ecto.Changeset{}}

  """
  def delete_follow(%Follow{} = follow) do
    Repo.delete(follow)
  end

  defp join_direction(direction) do
    if direction == :to do
      dynamic([f, u], f.follow_user_id == u.id)
    else
      dynamic([f, u], f.user_id == u.id)
    end
  end

  defp where_direction(user_id, direction) do
    if direction == :to do
      dynamic([f], f.user_id == ^user_id)
    else
      dynamic([f], f.follow_user_id == ^user_id)
    end
  end
end
