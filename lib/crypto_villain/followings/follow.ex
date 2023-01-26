defmodule CryptoVillain.Followings.Follow do
  use Ecto.Schema
  import Ecto.Changeset

  schema "followings" do

    field :user_id, :id
    field :follow_user_id, :id

    timestamps()
  end

  @doc false
  def changeset(follow, attrs) do
    follow
    |> cast(attrs, [:user_id, :follow_user_id])
    |> validate_required([:user_id, :follow_user_id])
    |> unique_constraint(:following_users_constraint, name: :following_users_index)
  end
end
