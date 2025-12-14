defmodule HiwiWeb.Auth.AuthController do
  use HiwiWeb, :controller

  alias Hiwi.Users

  def show_registration_page(conn, _params) do
    changeset = Users.build_registration_changeset()
    render(conn, :register, changeset: changeset)
  end

  def show_login_page(conn, _params) do
    changeset = Users.build_login_changeset()
    render(conn, :login, changeset: changeset)
  end

  def register_user(conn, %{"user" => user_params}) do
    case Users.register_user(user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Account successfully created, please login.")
        |> redirect(to: ~p"/auth/login")

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Ups, please fill in the form correctly.")
        |> render(:register, changeset: changeset)
    end
  end

  def authenticate_user(conn, %{"user" => user_params}) do
    case Users.authenticate_user(user_params["email"], user_params["password"]) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome back, #{user.fullname}")
        |> put_session(:user_id, user.id)
        |> redirect(to: ~p"/")

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Ups, please check your credentials")
        |> redirect(to: ~p"/auth/login")
    end
  end

  def logout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> put_flash(:info, "You've been signed out")
    |> redirect(to: "/")
  end
end
