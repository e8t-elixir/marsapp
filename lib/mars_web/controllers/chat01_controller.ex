defmodule MarsWeb.Chat01Controller do
  use MarsWeb, {:controller, [put_default_views: false]}

  plug :put_root_layout, {MarsWeb.Chat01View, :root}
  plug :put_view, Phoenix.Controller.__view__(__MODULE__)

  # define `index` action
  def index(conn, _params) do
    Phoenix.Controller.__view__(__MODULE__) |> IO.inspect(label: "char01")
    # layout(conn) |> IO.inspect(label: "char01")
    render(conn, "index.html")
  end
end
