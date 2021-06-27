defmodule MarsWeb.Presence do
  use Phoenix.Presence,
    otp_app: :mars,
    pubsub_server: Mars.PubSub
end
