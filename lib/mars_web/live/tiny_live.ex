defmodule MarsWeb.TinyLive do
  use MarsWeb, :live_view

  def render(assigns) do
    ~L"""
    Current temperature: <%= @temperature %>
    """
  end

  def mount(_params, _session, socket) do
    temperature = 100
    {:ok, assign(socket, :temperature, temperature)}
  end
end
