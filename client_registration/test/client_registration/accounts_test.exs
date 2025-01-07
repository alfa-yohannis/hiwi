defmodule ClientRegistration.AccountsTest do
  use ClientRegistration.DataCase

  alias ClientRegistration.Accounts

  describe "clients" do
    alias ClientRegistration.Accounts.Client

    import ClientRegistration.AccountsFixtures

    @invalid_attrs %{name: nil, email: nil, phone: nil}

    test "list_clients/0 returns all clients" do
      client = client_fixture()
      assert Accounts.list_clients() == [client]
    end

    test "get_client!/1 returns the client with given id" do
      client = client_fixture()
      assert Accounts.get_client!(client.id) == client
    end

    test "create_client/1 with valid data creates a client" do
      valid_attrs = %{name: "some name", email: "some email", phone: "some phone"}

      assert {:ok, %Client{} = client} = Accounts.create_client(valid_attrs)
      assert client.name == "some name"
      assert client.email == "some email"
      assert client.phone == "some phone"
    end

    test "create_client/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_client(@invalid_attrs)
    end

    test "update_client/2 with valid data updates the client" do
      client = client_fixture()
      update_attrs = %{name: "some updated name", email: "some updated email", phone: "some updated phone"}

      assert {:ok, %Client{} = client} = Accounts.update_client(client, update_attrs)
      assert client.name == "some updated name"
      assert client.email == "some updated email"
      assert client.phone == "some updated phone"
    end

    test "update_client/2 with invalid data returns error changeset" do
      client = client_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_client(client, @invalid_attrs)
      assert client == Accounts.get_client!(client.id)
    end

    test "delete_client/1 deletes the client" do
      client = client_fixture()
      assert {:ok, %Client{}} = Accounts.delete_client(client)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_client!(client.id) end
    end

    test "change_client/1 returns a client changeset" do
      client = client_fixture()
      assert %Ecto.Changeset{} = Accounts.change_client(client)
    end
  end
end
