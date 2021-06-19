defmodule MarsWeb.ProductFormLive do
  use MarsWeb, :live_view

  alias Mars.Products
  alias Mars.Products.Product

  def mount(_params, %{"action" => action, "csrf_token" => csrf_token}, socket) do
    assigns = [
      conn: socket,
      action: action,
      csrf_token: csrf_token,
      changeset: Products.change_product(%Product{})
    ]

    {:ok, assign(socket, assigns)}
  end

  def render(assigns) do
    assigns
    |> Map.get(:flash)
    # |> Map.keys()
    |> IO.inspect(label: "handle_event")

    MarsWeb.ProductView.render("form.html", assigns)
  end

  def handle_event("validate", %{"product" => product_params}, socket) do
    changeset =
      %Product{}
      |> Product.changeset(product_params)
      |> Map.put(:action, :insert)
      |> IO.inspect(label: "handle_event")

    {:noreply, assign(socket, changeset: changeset)}
  end
end
