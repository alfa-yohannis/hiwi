defmodule Hello.TellersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Hello.Tellers` context.
  """

  @doc """
  Generate a teller.
  """
  def teller_fixture(attrs \\ %{}) do
    {:ok, teller} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Hello.Tellers.create_teller()

    teller
  end
end
