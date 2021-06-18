defmodule Mars.Repo do
  use Ecto.Repo,
    otp_app: :mars,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 5
end
