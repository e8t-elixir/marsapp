defmodule Mars.Products.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :description, :string
    field :name, :string
    field :price, :float

    has_many :variants, Mars.Products.Variant

    timestamps()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :description, :price])
    |> validate_required([:name, :description, :price])
    |> validate_length(:name, min: 2)
    |> validate_number(:price, greater_than: 0)
  end
end
