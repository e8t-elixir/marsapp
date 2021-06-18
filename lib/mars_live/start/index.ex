# https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#module-life-cycle

defmodule MarsLive.ThermostatLive.Index do
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_view
  use MarsWeb, :live_view

  # def render(assigns) do
  #   ~L"""
  #   Current temperature: <%= @temperature %>
  #   """
  # end

  # def mount(_params, %{"current_user_id" => user_id}, socket) do
  #   temperature = Thermostat.get_user_reading(user_id)
  def mount(_params, _session, socket) do
    temperature = 100
    {:ok, assign(socket, :temperature, temperature)}
  end
end
