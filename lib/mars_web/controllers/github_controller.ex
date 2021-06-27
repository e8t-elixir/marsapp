defmodule MarsWeb.GithubController do
  use MarsWeb, :controller
  alias Phoenix.LiveView

  def index(conn, _) do
    LiveView.Controller.live_render(conn, MarsWeb.GithubView, session: %{})
  end
end
