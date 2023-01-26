defmodule CryptoVillain.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :content, :string
    field :image, :string
    belongs_to :user, CryptoVillain.Accounts.User
    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:content, :image, :user_id])
    |> validate_required([:content, :user_id])
    |> validate_length(:content, min: 10, max: 500)
  end
end
