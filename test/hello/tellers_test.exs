defmodule Hello.TellersTest do
  use Hello.DataCase

  alias Hello.Tellers

  describe "tellers" do
    alias Hello.Tellers.Teller

    import Hello.TellersFixtures

    @invalid_attrs %{name: nil}

    test "list_tellers/0 returns all tellers" do
      teller = teller_fixture()
      assert Tellers.list_tellers() == [teller]
    end

    test "get_teller!/1 returns the teller with given id" do
      teller = teller_fixture()
      assert Tellers.get_teller!(teller.id) == teller
    end

    test "create_teller/1 with valid data creates a teller" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Teller{} = teller} = Tellers.create_teller(valid_attrs)
      assert teller.name == "some name"
    end

    test "create_teller/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tellers.create_teller(@invalid_attrs)
    end

    test "update_teller/2 with valid data updates the teller" do
      teller = teller_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Teller{} = teller} = Tellers.update_teller(teller, update_attrs)
      assert teller.name == "some updated name"
    end

    test "update_teller/2 with invalid data returns error changeset" do
      teller = teller_fixture()
      assert {:error, %Ecto.Changeset{}} = Tellers.update_teller(teller, @invalid_attrs)
      assert teller == Tellers.get_teller!(teller.id)
    end

    test "delete_teller/1 deletes the teller" do
      teller = teller_fixture()
      assert {:ok, %Teller{}} = Tellers.delete_teller(teller)
      assert_raise Ecto.NoResultsError, fn -> Tellers.get_teller!(teller.id) end
    end

    test "change_teller/1 returns a teller changeset" do
      teller = teller_fixture()
      assert %Ecto.Changeset{} = Tellers.change_teller(teller)
    end
  end
end
