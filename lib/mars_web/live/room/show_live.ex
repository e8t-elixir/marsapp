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
    <button id='join-call' class='button' phx-hook='JoinCall' phx-click='join_call'>Join Call</button>

    <%# Hidden Elements %>

    <div id="offer_requests">
      <%= for request <- @offer_requests do %>
      <span id="offer-request-<%= request.from_user.uuid %>" phx-hook='HandleOfferRequest' data-from-user-uuid="<%= request.from_user.uuid %>"></span>
      <% end %>
    </div>

    <div id="offers">
      <%= for offer <- @offers do %>
        <span id="offer-<%= offer['from_user'] %>" phx-hook='HandleOffer' data-from-user-uuid="<%= offer["from_user"]%>" data-sdp="<%= offer["description"]["sdp"] %>"></span>
      <% end %>
    </div>

    <div id="answers">
      <%= for answer <- @answers do %>
        <span id="answer-<%= answer['from_user'] %>" phx-hook='HandleAnswer' data-from-user-uuid="<%= answer["from_user"]%>" data-sdp="<%= answer["description"]["sdp"] %>"></span>
      <% end %>
    </div>

    <div id="ice-candidates">
    <%= for ice_candidate_offer <- @ice_candidate_offers do %>
      <span id="ice-candidate-<%= ice_candidate_offer['from_user'] %>"phx-hook="HandleIceCandidateOffer" data-from-user-uuid="<%= ice_candidate_offer["from_user"] %>" data-ice-candidate="<%= Jason.encode!(ice_candidate_offer["candidate"]) %>"></span>
    <% end %>
    </div>
    """
  end

  @impl true
  def mount(%{"slug" => slug} = params, _session, socket) do
    params |> IO.inspect(label: "show-mount")
    user = create_connected_user()
    topic = "room:#{slug}"
    user_own_topic = "#{topic}:#{user.uuid}" |> IO.inspect(label: "send_direct_message_mount")
    # 订阅 room topic 追踪用户列表
    Phoenix.PubSub.subscribe(Mars.PubSub, topic)
    {:ok, _} = Presence.track(self(), topic, user.uuid, %{})
    Phoenix.PubSub.subscribe(Mars.PubSub, user_own_topic)

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
         |> assign(:connected_users, [])
         |> assign(:offer_requests, [])
         |> assign(:ice_candidate_offers, [])
         |> assign(:offers, [])
         |> assign(:answers, [])}
    end
  end

  @impl true
  def handle_event("join_call", _params, socket) do
    # connected_users => [user.uuid]
    for user <- socket.assigns.connected_users do
      send_direct_message(socket.assigns.slug, user, "request_offer", %{
        from_user: socket.assigns.user
      })
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("new_ice_candidate", payload, socket) do
    # payload |> IO.inspect(label: 'event_new_ice_candidate')
    payload = Map.merge(payload, %{"from_user" => socket.assigns.user.uuid})
    send_direct_message(socket.assigns.slug, payload["toUser"], "new_ice_candidate", payload)
    {:noreply, socket}
  end

  @impl true
  def handle_event("new_offer", payload, socket) do
    payload = Map.merge(payload, %{"from_user" => socket.assigns.user.uuid()})
    payload |> IO.inspect(label: "event_new_offer")
    send_direct_message(socket.assigns.slug, payload["toUser"], "new_offer", payload)
    {:noreply, socket}
  end

  @impl true
  def handle_event("new_answer", payload, socket) do
    payload |> IO.inspect(label: "event_new_answer")
    payload = Map.merge(payload, %{"from_user" => socket.assigns.user.uuid})
    send_direct_message(socket.assigns.slug, payload["toUser"], "new_answer", payload)
    {:noreply, socket}
  end

  @impl true
  def handle_info(%Broadcast{event: "presence_diff"}, socket) do
    {:noreply,
     socket
     |> assign(:connected_users, list_present(socket))}
  end

  @impl true
  def handle_info(%Broadcast{event: "request_offer", payload: request}, socket) do
    {
      :noreply,
      socket
      |> assign(:offer_requests, socket.assigns.offer_requests ++ [request])
    }
  end

  @impl true
  def handle_info(%Broadcast{event: "new_ice_candidate", payload: payload}, socket) do
    payload |> IO.inspect(label: "info_new_ice_candidate")

    {:noreply,
     socket
     |> assign(:ice_candidate_offers, socket.assigns.ice_candidate_offers ++ [payload])}
  end

  @impl true
  def handle_info(%Broadcast{event: "new_offer", payload: payload}, socket) do
    payload |> IO.inspect(label: "info_new_offer")

    {:noreply,
     socket
     |> assign(:offers, socket.assigns.offers ++ [payload])}
  end

  @impl true
  def handle_info(%Broadcast{event: "new_answer", payload: payload}, socket) do
    {:noreply,
     socket
     |> assign(:answers, socket.assigns.answers ++ [payload])}
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

  # to_user: uuid
  defp send_direct_message(slug, to_user, event, payload) do
    user_own_topic = "room:#{slug}:#{to_user}" |> IO.inspect(label: "send_direct_message")

    MarsWeb.Endpoint.broadcast_from(
      self(),
      user_own_topic,
      event,
      payload
    )
  end
end
