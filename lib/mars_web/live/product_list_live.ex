defmodule MarsWeb.ProductListLive do
  use Phoenix.LiveView
  alias Mars.Products

  def mount(_session, socket) do
    products = if connected?(socket), do: Products.list_products(), else: []

    assigns = [
      conn: socket,
      products: products
    ]

    {:ok, assign(socket, assigns)}
  end

  def render(assigns) do
    # templates/product/products.html.leex
    MarsWeb.ProductView.render("products.html", assigns)
  end
end
