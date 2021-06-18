defmodule MarsWeb.ProductListLive do
  use MarsWeb, :live_view

  def render(assigns) do
    ~L"""
    Current temperature: <%= @temperature %>
    """
  end

  def mount(_session, socket) do
    temperature = 100
    {:ok, assign(socket, :temperature, temperature)}
  end
end

defmodule MarsWeb.ProductListLiveFix do
  use Phoenix.LiveView
  alias Mars.Products

  def mount(_session, socket) do
    # products = if connected?(socket), do: Products.list_products(), else: []

    # assigns = [
    #   conn: socket,
    #   # csrf_token: csrf_token
    #   products: products,
    #   name: "John Wick"
    # ]

    # {:ok, socket |> assign(:name, "John Wick")}
    # {:ok, assign(socket, assigns)}
    temperature = 100
    {:ok, assign(socket, :name, temperature)}
  end

  def render(assigns) do
    # templates/product/products.html.leex
    assigns |> IO.inspect(label: "render-product-list")
    # MarsWeb.ProductView.render("products.html", assigns)
    ~L"""
    <%= @name %>
    """
  end
end
