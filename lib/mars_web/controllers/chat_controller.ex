defmodule MarsWeb.GithubController do
  use MarsWeb, :controller
  alias Mars.Chat
  alias MarsWeb.ChatView
  alias Phoenix.LiveView

  def show(conn, %{"id" => chat_id}) do
    # chat = Chat.get_chat(chat_id)
  end
