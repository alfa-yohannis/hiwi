defmodule HiwiWeb.Guest.GuestController do
    use HiwiWeb, :controller

    def index(conn, _params) do
        render(conn, :index)
    end
end
