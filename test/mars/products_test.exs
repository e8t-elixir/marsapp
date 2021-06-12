defmodule Mars.ProductsTest do
  use Mars.DataCase

  alias Mars.Products

  describe "products" do
    alias Mars.Products.Product

    @valid_attrs %{description: "some description", name: "some name", price: 120.5}
    @update_attrs %{
      description: "some updated description",
      name: "some updated name",
      price: 456.7
    }
    @invalid_attrs %{description: nil, name: nil, price: nil}

    def product_fixture(attrs \\ %{}) do
      {:ok, product} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Products.create_product()

      product
    end

    test "list_products/0 returns all products" do
      product = product_fixture()
      assert Products.list_products() == [product]
    end

    test "get_product!/1 returns the product with given id" do
      product = product_fixture()
      assert Products.get_product!(product.id) == product
    end

    test "create_product/1 with valid data creates a product" do
      assert {:ok, %Product{} = product} = Products.create_product(@valid_attrs)
      assert product.description == "some description"
      assert product.name == "some name"
      assert product.price == 120.5
    end

    test "create_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Products.create_product(@invalid_attrs)
    end

    test "update_product/2 with valid data updates the product" do
      product = product_fixture()
      assert {:ok, %Product{} = product} = Products.update_product(product, @update_attrs)
      assert product.description == "some updated description"
      assert product.name == "some updated name"
      assert product.price == 456.7
    end

    test "update_product/2 with invalid data returns error changeset" do
      product = product_fixture()
      assert {:error, %Ecto.Changeset{}} = Products.update_product(product, @invalid_attrs)
      assert product == Products.get_product!(product.id)
    end

    test "delete_product/1 deletes the product" do
      product = product_fixture()
      assert {:ok, %Product{}} = Products.delete_product(product)
      assert_raise Ecto.NoResultsError, fn -> Products.get_product!(product.id) end
    end

    test "change_product/1 returns a product changeset" do
      product = product_fixture()
      assert %Ecto.Changeset{} = Products.change_product(product)
    end
  end

  describe "variants" do
    alias Mars.Products.Variant

    @valid_attrs %{name: "some name", value: "some value"}
    @update_attrs %{name: "some updated name", value: "some updated value"}
    @invalid_attrs %{name: nil, value: nil}

    setup do
      product = product_fixture()
      {:ok, product: product}
    end

    # def variant_fixture(attrs \\ %{}) do
    #   {:ok, variant} =
    #     attrs
    #     |> Enum.into(@valid_attrs)
    #     |> Products.create_variant()

    #   variant
    # end

    def variant_fixture(product, attrs \\ %{}) do
      attrs = Enum.into(attrs, @valid_attrs)
      {:ok, variant} = Products.create_variant(product, attrs)

      variant
    end

    test "list_variants/0 returns all variants", %{product: product} do
      variant = variant_fixture(product)
      assert Products.list_variants(product) == [variant]
    end

    test "get_variant!/1 returns the variant with given id", %{product: product} do
      variant = variant_fixture(product)
      assert Products.get_variant!(product, variant.id) == variant
    end

    test "create_variant/1 with valid data creates a variant", %{product: product} do
      assert {:ok, %Variant{} = variant} = Products.create_variant(product, @valid_attrs)
      assert variant.name == "some name"
      assert variant.value == "some value"
    end

    test "create_variant/1 with invalid data returns error changeset", %{product: product} do
      assert {:error, %Ecto.Changeset{}} = Products.create_variant(product, @invalid_attrs)
    end

    test "update_variant/2 with valid data updates the variant", %{product: product} do
      variant = variant_fixture(product)
      assert {:ok, %Variant{} = variant} = Products.update_variant(variant, @update_attrs)
      assert variant.name == "some updated name"
      assert variant.value == "some updated value"
    end

    test "update_variant/2 with invalid data returns error changeset", %{product: product} do
      variant = variant_fixture(product)
      assert {:error, %Ecto.Changeset{}} = Products.update_variant(variant, @invalid_attrs)
      assert variant == Products.get_variant!(product, variant.id)
    end

    test "delete_variant/1 deletes the variant", %{product: product} do
      variant = variant_fixture(product)
      assert {:ok, %Variant{}} = Products.delete_variant(variant)
      assert_raise Ecto.NoResultsError, fn -> Products.get_variant!(product, variant.id) end
    end

    test "change_variant/1 returns a variant changeset", %{product: product} do
      variant = variant_fixture(product)
      assert %Ecto.Changeset{} = Products.change_variant(variant)
    end
  end
end
