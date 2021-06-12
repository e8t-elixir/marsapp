defmodule Mars.Products.Variant do
  use Ecto.Schema
  import Ecto.Changeset

  schema "variants" do
    field :name, :string
    field :value, :string
    # field :product_id, :id
    belongs_to :product, Mars.Products.Product

    timestamps()
  end

  @doc false
  def changeset(variant, attrs) do
    variant
    |> cast(attrs, [:name, :value])
    |> validate_required([:name, :value])
    # name 为错误标签
    |> unique_constraint(:name, name: :variants_name_value_product_id_index)
  end
end
