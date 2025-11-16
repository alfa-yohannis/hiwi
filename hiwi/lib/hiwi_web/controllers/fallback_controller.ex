defmodule HiwiWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid Plug.Conn responses.
  (Ini file yang hilang dari backup)
  """
  use HiwiWeb, :controller

  # This clause handles Ecto.Changeset validation errors
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: HiwiWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  # This clause handles :not_found errors
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: HiwiWeb.ErrorJSON)
    |> render(:"404")
  end
end