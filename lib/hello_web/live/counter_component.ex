defmodule HelloWeb.QueueCounterComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <div><%= @queue_prefix %><%= @current_number %></div>
    """
  end
end
