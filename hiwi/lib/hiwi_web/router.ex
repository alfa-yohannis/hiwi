defmodule HiwiWeb.Router do
    use HiwiWeb, :router

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

    # --- HOMEPAGE ---
    scope "/", HiwiWeb.Home do
        pipe_through :browser

        get "/", HomeController, :index
    end

    # --- AUTHENTICATION (Login/Register) ---
    scope "/auth", HiwiWeb.Auth do
        pipe_through :browser

        get "/register", AuthController, :show_registration_page
        post "/register", AuthController, :register_user

        get "/login", AuthController, :show_login_page
        post "/login", AuthController, :authenticate_user

        get "/logout", AuthController, :logout
    end

    # --- QUEUE MANAGEMENT (Tugas Erdine) ---
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

        post "/:id/assign_teller", QueueController, :assign_teller
        delete "/:id/remove_teller/:user_id", QueueController, :remove_teller
    end

    # =======================================================
    # RUTE INVITATION (TUGAS ALEJANDRO - BARU DITAMBAHKAN)
    # =======================================================
    scope "/invitations", HiwiWeb do
        pipe_through :browser

        post "/create", InvitationController, :create

        # Halaman untuk Teller merespon undangan
        # URL: /invitations/respond?token=...
        get "/respond", InvitationController, :show
        post "/respond", InvitationController, :respond
    end
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
    # Rute Browser/LiveView (Milik Nopal - Kode Bawaan)
    # (Dibiarkan dikomentari sesuai file aslimu)
    # =======================================================

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
