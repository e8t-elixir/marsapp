defmodule MarsWeb.Router do
  use MarsWeb, :router

  import MarsWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {MarsWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MarsWeb do
    import MarsWeb.Live.Router

    pipe_through :browser

    live "/", PageLive, :index

    # liveless("/products", ProductListLive, :live_index)

    # @phoenix_routes
    # |> Enum.filter(fn route -> route.verb == :get and route.path == "/products" end)
    # |> IO.inspect(label: "phoenix_routes")

    # @phoenix_routes = cache_routes

    resources "/products", ProductController
    # new_line = __ENV__.line |> IO.inspect(label: "ENV line")

    # old =
    #   @phoenix_routes
    #   |> Enum.filter(fn route ->
    #     route.verb == :get and route.path == "/products" and
    #       route.plug == MarsWeb.ProductController
    #   end)
    #   |> hd()

    # # |> Map.get(:line)
    # %Phoenix.Router.Route{old | line: new_line}
    # |> IO.inspect(label: "phoenix_routes")

    live "/tiny", TinyLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", MarsWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: MarsWeb.Telemetry
    end
  end

  ## Authentication routes

  scope "/", MarsWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/", MarsWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email
  end

  scope "/", MarsWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :confirm
  end
end
