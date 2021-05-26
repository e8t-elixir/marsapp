defmodule MarsLive.OnlineLive.Index do
  use MarsWeb, :live_view

  alias Mars.Presence
  alias Mars.PubSub

  @presence "mars:presence"

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    # {:ok, assign(socket, query: "", results: %{})}
    # params |> IO.inspect(label: 'page live mount params')

    # user = session |> Map.get("current_user", %{id: 9999, name: "John Wick"})

    # user =
    #   with tag <- System.os_time(:second) |> Integer.to_string() do
    #     %{id: tag, name: "John Wick ##{tag |> String.slice(-4, 4)}"}
    #   end
    user = %{id: id, name: "John Wick ##{id}"}

    if connected?(socket) do
      {:ok, _} =
        Presence.track(self(), @presence, user[:id], %{
          name: user[:name],
          joined_at: :os.system_time(:seconds)
        })

      Phoenix.PubSub.subscribe(PubSub, @presence)
    end

    # Presence.list(@presence) |> IO.inspect(label: 'Presence.list')

    {:ok,
     socket
     |> assign(:current_user, user)
     |> assign(:users, %{})
     |> handle_joins(Presence.list(@presence))}
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(PubSub, @presence)
    end

    {:ok,
     socket
     |> assign(:current_user, %{})
     |> assign(:users, %{})
     |> handle_joins(Presence.list(@presence))}
  end

  @impl true
  def handle_event("suggest", %{"q" => query}, socket) do
    {:noreply, assign(socket, results: search(query), query: query)}
  end

  @impl true
  def handle_event("search", %{"q" => query}, socket) do
    case search(query) do
      %{^query => vsn} ->
        {:noreply, redirect(socket, external: "https://hexdocs.pm/#{query}/#{vsn}")}

      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "No dependencies found matching \"#{query}\"")
         |> assign(results: %{}, query: query)}
    end
  end

  defp search(query) do
    if not MarsWeb.Endpoint.config(:code_reloader) do
      raise "action disabled when not in development"
    end

    for {app, desc, vsn} <- Application.started_applications(),
        app = to_string(app),
        String.starts_with?(app, query) and not List.starts_with?(desc, ~c"ERTS"),
        into: %{},
        do: {app, vsn}
  end

  # Presence: online user

  # behaviour
  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff", payload: diff}, socket) do
    {:noreply, socket |> handle_leaves(diff.leaves) |> handle_joins(diff.joins)}
  end

  defp handle_joins(socket, joins) do
    # joins |> IO.inspect(label: "handle_joins")

    Enum.reduce(joins, socket, fn {user, %{metas: [meta | _]}}, socket ->
      assign(socket, :users, Map.put(socket.assigns.users, user, meta))
    end)
  end

  defp handle_leaves(socket, leaves) do
    # leaves |> IO.inspect(label: "handle_leaves")

    Enum.reduce(leaves, socket, fn {user, _}, socket ->
      assign(socket, :users, Map.delete(socket.assigns.users, user))
    end)
  end
end
