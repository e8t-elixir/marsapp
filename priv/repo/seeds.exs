# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Mars.Repo.insert!(%Mars.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Mars.Products

product = fn key ->
  %{
    description: "product-#{key}-desc",
    name: "product-#{key}-name",
    price: Enum.random(1..100)
  }
end

1..100 |> Enum.each(fn key -> product.(key) |> Products.create_product() end)
