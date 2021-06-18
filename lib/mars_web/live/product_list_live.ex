defmodule MarsWeb.ProductListLive do
  use Phoenix.LiveView
  alias Mars.Products
  alias MarsWeb.Router.Helpers, as: Routes
  alias MarsWeb.ProductListLive
  alias MarsWeb.ProductController

  def mount(_params, _session, socket) do
    # products = if connected?(socket), do: Products.list_products(), else: []
    # %{
    #   entries: entries,
    #   page_number: page_number,
    #   page_size: page_size,
    #   total_entries: total_entries,
    #   total_pages: total_pages
    # } = if connected?(socket), do: Products.paginate_products(), else: %Scrivener.Page{}

    # products |> IO.inspect(label: "mount-products")

    # assigns = [
    #   conn: socket,
    #   # csrf_token: csrf_token
    #   products: entries,
    #   page_number: page_number || 0,
    #   page_size: page_size || 0,
    #   total_entries: total_entries || 0,
    #   total_pages: total_pages || 0,
    #   name: "John Wick"
    # ]

    assigns = assign_page(1) |> Keyword.put(:conn, socket)
    {:ok, assign(socket, assigns)}
    # {:ok, assign(socket, conn: socket, params: params, products: [])}
  end

  def render(assigns) do
    # assigns.conn |> IO.inspect(label: "render-product-list")
    MarsWeb.ProductView.render("products.html", assigns)
    # MarsWeb.ProductView.render("index.html", assigns)
  end

  # def render(assigns) do
  #   # templates/product/products.html.leex
  #   assigns |> IO.inspect(label: "render-product-list-index")
  #   MarsWeb.ProductView.render("index.html", assigns)
  #   # MarsWeb.ProductView.render("index.html", assigns)
  # end

  def handle_event("nav", %{"page" => page}, socket) do
    page |> IO.inspect(label: "handle_event")
    # handling the phx-click events on the links.
    # {:noreply, socket}
    # Routes.live_path(socket, ProductListLive, page: page) |> IO.inspect(label: "live_path")
    # Routes.product_path(socket, :index, page: page) |> IO.inspect(label: "live_path")
    # {:noreply, live_redirect(socket, to: Routes.live_path(socket, ProductListLive, page: page))}
    # {:noreply, push_redirect(socket, to: Routes.live_path(socket, ProductListLive, page: page))}
    # {:noreply, push_redirect(socket, to: Routes.product_path(socket, :index, page: page))}
    assigns = assign_page(page)
    {:noreply, assign(socket, assigns)}
  end

  # def handle_params(%{"page" => page}, _, socket) do
  #   assigns = assign_page(page)
  #   {:noreply, assign(socket, assigns)}
  # end

  # def handle_params(_, _, socket) do
  #   assigns = assign_page(nil)
  #   {:noreply, assign(socket, assigns)}
  # end

  defp assign_page(page_number) do
    Products.paginate_products(page: page_number)
    |> map_struct_tw([
      [:entries, :products],
      :page_number,
      :page_size,
      :total_entries,
      :total_pages
    ])
  end

  defp map_struct_tw(struct, keys) do
    for key <- keys do
      [old, new] = get_key(key)
      default_value = if new == :products, do: [], else: 0
      {new, struct |> Map.get(old, default_value)}
    end
  end

  defp get_key([old, new]), do: [old, new]
  defp get_key(key), do: [key, key]
end
