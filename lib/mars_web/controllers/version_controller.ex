defmodule MarsWeb.VersionController do
  use MarsWeb, :controller

  def index(conn, _params) do
    render(conn, "index.json", version: phx_version())
  end

  defp phx_version(),
    do:
      Mars.MixProject.project()[:deps]
      |> Enum.filter(&(fn dep -> elem(dep, 0) == :phoenix end).(&1))
      |> hd()
      |> elem(1)
end
