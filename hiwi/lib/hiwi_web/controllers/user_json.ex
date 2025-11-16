defmodule HiwiWeb.UserJSON do
  @moduledoc """
  Renders a user response (only necessary fields).
  """
  def show(%{user: user}) do
    %{data: data(user)}
  end

  defp data(user) do
    %{
      id: user.id,
      email: user.email,
      full_name: user.full_name,
      phone_number: user.phone_number,
      inserted_at: user.inserted_at
    }
  end
end