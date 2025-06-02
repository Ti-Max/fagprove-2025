defmodule MyPodcastsWeb.Router do
  use MyPodcastsWeb, :router

  import MyPodcastsWeb.UserAuth

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {MyPodcastsWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:fetch_current_user)
  end

  pipeline :api do
    plug(:accepts, ["xml"])
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:my_podcasts, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: MyPodcastsWeb.Telemetry)
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end

  scope "/", MyPodcastsWeb do
    pipe_through(:api)

    get("/rss_feed/:feed_hash", RssController, :index)
    get("/file/:file_hash", FileController, :index)
  end

  ## Authentication routes
  scope "/", MyPodcastsWeb do
    pipe_through([:browser, :redirect_if_user_is_authenticated])

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{MyPodcastsWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live("/users/register", UserRegistrationLive, :new)
      live("/users/log_in", UserLoginLive, :new)
    end

    post("/users/log_in", UserSessionController, :create)
  end

  scope "/", MyPodcastsWeb do
    pipe_through([:browser, :require_authenticated_user])

    live_session :require_authenticated_user,
      on_mount: [{MyPodcastsWeb.UserAuth, :ensure_authenticated}] do
      live("/", New)

      live("/files", FileLive.Index, :index)
      live("/files/:id/edit", FileLive.Index, :edit)

      live("/users/settings", UserSettingsLive, :edit)
    end
  end

  scope "/", MyPodcastsWeb do
    pipe_through([:browser])

    delete("/users/log_out", UserSessionController, :delete)
  end
end
