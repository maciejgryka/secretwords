defmodule Secretwords.Repo do
  use Ecto.Repo,
    otp_app: :secretwords,
    adapter: Ecto.Adapters.Postgres
end
