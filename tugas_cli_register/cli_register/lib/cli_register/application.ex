defmodule CliRegister.Application do
  use Application

  alias CliRegister.Repo

  def start(_type, _args) do
    children = [
      Repo
    ]

    opts = [strategy: :one_for_one, name: CliRegister.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
