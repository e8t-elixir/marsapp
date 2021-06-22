defmodule MarsWeb.PWA01Controller do
  # use MarsWeb, {:controller, [put_default_views: false]}
  use MarsWeb, :controller

  # plug :put_view, Phoenix.Controller.__view__(__MODULE__)

  # define `index` action
  def index(conn, _params) do
    # Phoenix.Controller.__view__(__MODULE__) |> IO.inspect(label: __MODULE__)
    # layout(conn) |> IO.inspect(label: "char01")
    render(conn, "index.html")
  end
end
