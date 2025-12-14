defmodule ClientRegistration.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ClientRegistration.Accounts` context.
  """

  @doc """
  Generate a client.
  """
  def client_fixture(attrs \\ %{}) do
    {:ok, client} =
      attrs
      |> Enum.into(%{
        email: "some email",
        name: "some name",
        phone: "some phone"
      })
      |> ClientRegistration.Accounts.create_client()

    client
  end
end
