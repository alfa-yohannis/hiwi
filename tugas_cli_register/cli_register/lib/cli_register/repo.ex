defmodule CliRegister.Repo do
  use Ecto.Repo,
    otp_app: :cli_register,
    adapter: Ecto.Adapters.Postgres
end
