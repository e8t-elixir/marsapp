defmodule MarsWeb.Room.NewLive do
  use MarsWeb, :live_view

  alias Mars.Repo
  alias Mars.Organizer.Room

  @impl true
  def render(assigns) do
    # <%= form_for @changeset, "#", [phx_change: "validate", phx_submit: "save"], fn f -> %>
    # <% end %>
    ~L"""
    <h3>Create a New Room</h3>
    <div>
      <%= f = form_for @changeset, "#", [phx_change: "validate", phx_submit: "save"] %>
        <%= text_input f, :title, placeholder: "Title" %>
        <%= error_tag f, :title %>
        <%= text_input f, :slug, placeholder: "room-slug" %>
        <%= error_tag f, :slug %>
        <%= submit "Save" %>
      </form>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> put_changeset()}
  end

  @impl true
  def handle_event("validate", %{"room" => room_params} = params, socket) do
    params |> IO.inspect(label: "validate-event")
    {:noreply, socket |> put_changeset(room_params)}
  end

  @impl true
  def handle_event("save", params, %{assigns: %{changeset: changeset}} = socket) do
    params |> IO.inspect(label: "save-event")
    changeset |> IO.inspect(label: "save-event")

    case Repo.insert(changeset) |> IO.inspect(label: "save-insert-event") do
      {:ok, room} ->
        {:noreply, socket |> push_redirect(to: Routes.room_show_path(socket, :show, room.slug))}

      {:error, changeset} ->
        {:noreply,
         socket |> assign(:changeset, changeset) |> put_flash(:error, "Could not save the room")}
    end
  end

  defp put_changeset(socket, params \\ %{}) do
    socket
    |> assign(:changeset, Room.changeset(%Room{}, params))
  end
end
