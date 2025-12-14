defmodule ClientRegistration.Repo do
  use Ecto.Repo,
    otp_app: :client_registration,
    adapter: Ecto.Adapters.Postgres
end
