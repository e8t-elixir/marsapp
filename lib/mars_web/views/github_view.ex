defmodule MarsWeb.GithubView do
  use Phoenix.LiveView

  @impl true
  def render(assigns) do
    # render(assigns)
    """
    <div class="">
      <div>
      <%= @deploy_step %>
      </div>
      <hr />
      <div class="">
        <div>
          <div>
            <button phx-click="github_deploy" phx-value-myvar1="val1">Deploy to GitHub</button>
          </div>
          Status: <%= @deploy_step %>
        </div>
      </div>
    </div>
    """
  end

  # mount/3 
  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, deploy_step: "Ready!")}
  end

  @impl true
  def handle_event("github_deploy", value, socket) do
    value |> IO.inspect(label: "event_deploy_step")
    delay()
    send(self(), :create_org)
    {:noreply, assign(socket, deploy_step: "Starting deploy ...")}
  end

  @impl true
  def handle_info(:create_org, socket) do
    delay()
    send(self(), {:create_repo, :org})
    {:noreply, assign(socket, deploy_step: "Creating GitHub org ...")}
  end

  @impl true
  def handle_info({:create_repo, :org}, socket) do
    delay()
    send(self(), {:push_contents, :repo})
    {:noreply, assign(socket, deploy_step: "Creating GitHub repo ...")}
  end

  @impl true
  def handle_info({:push_contents, :repo}, socket) do
    delay()
    send(self(), :done)
    {:noreply, assign(socket, deploy_step: "Pushing to repo ...")}
  end

  @impl true
  def handle_info(:done, socket) do
    delay()
    {:noreply, assign(socket, deploy_step: "Done!")}
  end

  def delay() do
    receive do
    after
      1_000 -> "DONE"
    end
  end
end
