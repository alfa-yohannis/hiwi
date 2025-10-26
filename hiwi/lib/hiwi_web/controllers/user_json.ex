defmodule HiwiWeb.UserJSON do
  def show(%{user: user}) do
    %{data: data(user)}
  end

  defp data(user) do
    %{
      id: user.id,
      email: user.email,
      inserted_at: user.inserted_at
    }
  end
end
