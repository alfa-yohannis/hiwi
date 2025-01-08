defmodule HelloWeb.Plugs.SetUser do
  import Plug.Conn

  alias Hello.Repo
  alias Hello.User
  alias Hello.Tellers.Teller
  alias Hello.Clients.Client

  def init(_params), do: nil

  def call(conn, _params) do
    cond do
      # Check if the session contains a teller ID
      teller_id = get_session(conn, :teller_id) ->
        if teller = Repo.get(Teller, teller_id) do
          assign(conn, :user, %{id: teller.id, username: teller.username, role: "Teller"})
        else
          assign(conn, :user, nil)
        end

      # Check if the session contains a GitHub user ID
      user_id = get_session(conn, :user_id) ->
        if user = Repo.get(User, user_id) do
          IO.inspect(user, label: "User Found")
          assign(conn, :user, %{id: user.id, email: user.email, role: "Owner"})
        else
          IO.inspect(nil, label: "No User Found")
          assign(conn, :user, nil)
        end

      # Check if the session contains a client ID
      client_id = get_session(conn, :client_id) ->
        if client = Repo.get(Client, client_id) do
          assign(conn, :user, %{id: client.id, email: client.email, role: "Client"})
        else
          assign(conn, :user, nil)
        end

      # Default: no user is logged in
      true ->
        assign(conn, :user, nil)
    end
  end
end
