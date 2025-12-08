defmodule Hivex.Repo do
  use Ecto.Repo,
    otp_app: :hivex,
    adapter: Ecto.Adapters.Postgres
end
