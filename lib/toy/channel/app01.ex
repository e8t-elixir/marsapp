defmodule Toy.Channel.App01 do
  use MarsWeb, :channel
  alias Mars.Presence

  def join("head:topic", _params, socket) do
    send(self(), :after_join)
    {:ok, assign(socket, :user_id)}
  end
end
