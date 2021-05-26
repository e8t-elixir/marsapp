use Mix.Config

# Configure your database
config :mars, Mars.Repo,
  username: "dev",
  password: "xubuntudb",
  database: "mars_app_dev"

config :mars, Mars.Endpoint,
  http: [port: System.get_env("PORT", "4000") |> String.to_integer()]
