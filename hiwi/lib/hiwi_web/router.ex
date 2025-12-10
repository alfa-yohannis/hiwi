defmodule HiwiWeb.Router do
  use HiwiWeb, :router

  # # Ini (UserAuth) adalah plug Nopal untuk menangani login di browser
  # import HiwiWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {HiwiWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug HiwiWeb.Plugs.SetCurrentUser
    plug :put_layout, html: {HiwiWeb.Layouts, :app}
    # plug :fetch_current_user # Plug Nopal untuk cek login
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HiwiWeb.Home do
    pipe_through :browser

    get "/", HomeController, :index
  end

  scope "/auth", HiwiWeb.Auth do
    pipe_through :browser

    get "/register", AuthController, :show_registration_page
    post "/register", AuthController, :register_user

    get "/login", AuthController, :show_login_page
    post "/login", AuthController, :authenticate_user

    get "/logout", AuthController, :logout
  end

  # =======================================================
  # Rute API (Tempat Tugas Anda dan Tes Terminal)
  # =======================================================
  # scope "/api", HiwiWeb do
  #   pipe_through :api

  #   # Rute API Nopal (untuk registrasi via terminal/Invoke-WebRequest)
  #   post "/users", UserController, :register

  #   # Rute API Anda (untuk CRUD Queue via Postman)
  #   resources "/queues", QueueController
  # end
  # =======================================================


  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:hiwi, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: HiwiWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  # =======================================================
  # Rute Browser/LiveView (Milik Nopal, JANGAN DIHAPUS)
  # =======================================================

  ## Authentication routes
  # scope "/", HiwiWeb do
  #   pipe_through [:browser, :guest_layout, :redirect_if_user_is_authenticated]

  #   live_session :redirect_if_user_is_authenticated,
  #     on_mount: [{HiwiWeb.UserAuth, :redirect_if_user_is_authenticated}],
  #     layout: {HiwiWeb.Layouts, :guest} do
  #     live "/users/register", UserRegistrationLive, :new
  #     live "/users/log_in", UserLoginLive, :new
  #     live "/users/reset_password", UserForgotPasswordLive, :new
  #     live "/users/reset_password/:token", UserResetPasswordLive, :edit
  #   end

  #   post "/users/log_in", UserSessionController, :create
  # end

  # scope "/", HiwiWeb do
  #   pipe_through [:browser, :require_authenticated_user]

  #   live_session :require_authenticated_user,
  #     on_mount: [{HiwiWeb.UserAuth, :ensure_authenticated}] do
  #     live "/users/settings", UserSettingsLive, :edit
  #     live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
  #   end
  # end

  # scope "/", HiwiWeb do
  #   pipe_through [:browser]

  #   delete "/users/log_out", UserSessionController, :delete

  #   live_session :current_user,
  #     on_mount: [{HiwiWeb.UserAuth, :mount_current_user}] do
  #     live "/users/confirm/:token", UserConfirmationLive, :edit
  #     live "/users/confirm", UserConfirmationInstructionsLive, :new
  #   end
  # end
end
