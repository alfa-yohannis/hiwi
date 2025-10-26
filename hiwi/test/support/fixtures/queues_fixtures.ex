defmodule Hiwi.QueuesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Hiwi.Queues` context.
  """

  @doc """
  Generate a queue.
  """
  def queue_fixture(attrs \\ %{}) do
    {:ok, queue} =
      attrs
      |> Enum.into(%{
        current_number: 42,
        description: "some description",
        max_number: 42,
        name: "some name",
        prefix: "some prefix",
        status: "some status"
      })
      |> Hiwi.Queues.create_queue()

    queue
  end
end
