defmodule MarsWeb.Room.ShowLive do
  use MarsWeb, :live_view

  alias Mars.Organizer
  alias Mars.ConnectedUser
  alias MarsWeb.Presence
  alias Phoenix.Socket.Broadcast

  @impl true
  def render(assigns) do
    ~L"""
    <h3><%= @room.title %></h3>
    <p>user: <%= @user.uuid %>
    <h4>Connected Users:</h4>
    <ul>
    <%= for uuid <- @connected_users do %>
      <li><%= uuid %></li>
    <% end %>
    </ul>

    <div class='streams'>
      <video id='local-video' playsinline autoplay muted width='600px'></video>
      <hr />
      <%= for uuid <- @connected_users do %>
        <video id="video-remote-<%= uuid %>" data-user-uuid="<%= uuid %>" playsinline autoplay phx-hook="InitUser"></video>
      <% end %>
    </div>
    <button id='join-call' class='button' phx-hook='JoinCall'>Join Call</button>
    """
  end

  @impl true
  def mount(%{"slug" => slug} = params, _session, socket) do
    params |> IO.inspect(label: "show-mount")
    user = create_connected_user()
    topic = "room:#{slug}"
    Phoenix.PubSub.subscribe(Mars.PubSub, topic)
    {:ok, _} = Presence.track(self(), topic, user.uuid, %{})

    case Organizer.get_room(slug) do
      nil ->
        {:ok,
         socket
         |> put_flash(:error, "That room does not exist.")
         |> push_redirect(to: Routes.room_new_path(socket, :new))}

      room ->
        {:ok,
         socket
         |> assign(:room, room)
         # leex: @user
         |> assign(:user, user)
         |> assign(:slug, slug)
         |> assign(:connected_users, [])}
    end
  end

  @impl true
  def handle_info(%Broadcast{event: "presence_diff"}, socket) do
    {:noreply,
     socket
     |> assign(:connected_users, list_present(socket))}
  end

  defp create_connected_user() do
    %ConnectedUser{uuid: UUID.uuid4()}
  end

  defp list_present(socket) do
    Presence.list("room:#{socket.assigns.slug}")
    |> IO.inspect(label: "list_present")
    |> Enum.map(fn {k, _} -> k end)
    |> Enum.reject(&(&1 == socket.assigns.user.uuid))
  end
end
