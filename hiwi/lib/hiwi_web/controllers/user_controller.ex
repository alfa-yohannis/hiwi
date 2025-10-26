defmodule HiwiWeb.UserController do
  use HiwiWeb, :controller
  
  alias Hiwi.Accounts
  alias HiwiWeb.UserJSON
  alias HiwiWeb.ChangesetJSON
  
  action_fallback HiwiWeb.FallbackController

  @doc """
  Registers a new user (Placeholder sementara untuk Nopal - USR-REG).
  """
  def register(conn, %{"user" => user_params}) do
    # Ambil hanya data yang ada di skema sementara (hanya email)
    safe_params = Map.take(user_params, ["email"])

    case Accounts.register_user(safe_params) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> render(UserJSON, :show, user: user)

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(ChangesetJSON, :error, changeset: changeset)
    end
  end

  # Function called by the router (required by Phoenix)
  def init(opts), do: opts
end
