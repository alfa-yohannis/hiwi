defmodule HiwiWeb.Router do
  use HiwiWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {HiwiWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HiwiWeb do
    pipe_through :browser

    get "/", PageController, :home
  end
  
  # =======================================================
  # Rute API (Tempat Tugas Anda)
  # =======================================================
  scope "/api", HiwiWeb do
    pipe_through :api
    
    # Rute Nopal yang hilang (Membuat User/Registrasi)
    post "/users", UserController, :register 

    # Rute Anda (CRUD Queues)
    resources "/queues", QueueController, except: [:new, :edit]
  end


  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:hiwi, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: HiwiWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
