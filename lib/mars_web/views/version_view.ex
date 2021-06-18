defmodule MarsWeb.VersionView do
  use MarsWeb, :view 

  def render("index.json", %{version: version}) do
    %{version: version}
  end
end
