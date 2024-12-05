defmodule Hiwi.Repo do
  use Ecto.Repo,
    otp_app: :hiwi,
    adapter: Ecto.Adapters.Postgres
end
