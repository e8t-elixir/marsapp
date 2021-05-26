defmodule Mars.Presence do
  # application.ex
  # Start the PubSub system
  # {Phoenix.PubSub, name: Mars.PubSub},
  use Phoenix.Presence,
    otp_app: :mars,
    pubsub_server: Mars.PubSub
end
