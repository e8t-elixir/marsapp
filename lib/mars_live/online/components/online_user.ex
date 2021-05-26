defmodule MarsLive.Component.OnlineUser do
  use MarsWeb, :live_component

  def update(assigns, socket) do
    {:ok, socket |> assign(assigns)}
  end
end
