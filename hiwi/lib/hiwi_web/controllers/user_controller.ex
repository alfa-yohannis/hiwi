defmodule HiwiWeb.UserController do
  use HiwiWeb, :controller
  
  # Menggunakan Context dan JSON view yang benar
  alias Hiwi.Accounts
  alias HiwiWeb.UserJSON
  # Kita juga butuh ChangesetJSON untuk error
  alias HiwiWeb.ChangesetJSON 
  
  # Kita panggil FallbackController (yang sudah Anda buat)
  action_fallback HiwiWeb.FallbackController

  @doc """
  Registers a new user (USR-REG).
  """
  def register(conn, %{"user" => user_params}) do
    # Memanggil fungsi register_user dari Context Nopal
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        # Render menggunakan UserJSON
        |> render(UserJSON, :show, user: user) 

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        # Render error validasi
        |> render(ChangesetJSON, :error, changeset: changeset) 
    end
  end

  # === INI PERBAIKANNYA ===
  # FUNGSI WAJIB YANG HILANG (Penyebab error init/1)
  def init(opts), do: opts
end