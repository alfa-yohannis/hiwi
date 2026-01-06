defmodule HiwiWeb.Router do
  use HiwiWeb, :router

  # =========================
  # PIPELINES
  # =========================

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {HiwiWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug HiwiWeb.Plugs.SetCurrentUser
    plug :put_layout, html: {HiwiWeb.Layouts, :app}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # 🔑 WAJIB UNTUK GOOGLE OAUTH
  pipeline :ueberauth do
    plug Ueberauth
  end

  # =========================
  # HOMEPAGE
  # =========================
  scope "/", HiwiWeb.Home do
    pipe_through :browser

    get "/", HomeController, :index
  end

  # =========================
  # AUTHENTICATION
  # =========================
  scope "/auth", HiwiWeb.Auth do
    # ⬇️ WAJIB GABUNG browser + ueberauth
    pipe_through [:browser, :ueberauth]

    # Normal auth
    get "/register", AuthController, :show_registration_page
    post "/register", AuthController, :register_user

    get "/login", AuthController, :show_login_page
    post "/login", AuthController, :authenticate_user

    get "/logout", AuthController, :logout

    # Google OAuth (UEBERAUTH HANDLE)
    get "/google", AuthController, :request
    get "/google/callback", AuthController, :callback
  end

  # =========================
  # QUEUE MANAGEMENT
  # =========================
  scope "/queues", HiwiWeb.Queue do
    pipe_through :browser

    get "/", QueueController, :index
    post "/", QueueController, :register

    get "/new", QueueController, :show_registration_page

    get "/edit/:id", QueueController, :show_edit_page
    put "/edit/:id", QueueController, :edit

    delete "/delete/:id", QueueController, :delete

    get "/join/:id", QueueController, :show_join_queue_page
    post "/join/:id", QueueController, :join

    get "/entry/:id", QueueController, :show_queue_entry_page

    post "/:id/increment", QueueController, :increment
    post "/:id/increment-owner", QueueController, :increment_by_owner

    post "/:id/assign_teller", QueueController, :assign_teller
    delete "/:id/remove_teller/:user_id", QueueController, :remove_teller
  end

  # =========================
  # INVITATIONS
  # =========================
  scope "/invitations", HiwiWeb do
    pipe_through :browser

    post "/create", InvitationController, :create
    get "/show", InvitationController, :show
    post "/respond", InvitationController, :respond
  end

  # =========================
  # DEV TOOLS
  # =========================
  if Application.compile_env(:hiwi, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: HiwiWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
