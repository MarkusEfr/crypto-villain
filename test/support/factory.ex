defmodule CryptoVillain.Factory do
  use ExMachina.Ecto, repo: CryptoVillain.Repo
  use CryptoVillain.PostFactory
  use CryptoVillain.FollowFactory
  use CryptoVillain.UserFactory
end
