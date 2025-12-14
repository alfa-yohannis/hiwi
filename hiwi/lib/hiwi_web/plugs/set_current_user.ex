defmodule HiwiWeb.Plugs.SetCurrentUser do
  import Plug.Conn

  alias Hiwi.Repo
  alias Hiwi.Users.User

  def init(_params), do: nil

  def call(conn, _params) do
    user_id = get_session(conn, :user_id)

    cond do
      user = user_id && Repo.get(User, user_id) ->
        assign(conn, :current_user, user)

      true ->
        assign(conn, :current_user, nil)
    end
  end
end
