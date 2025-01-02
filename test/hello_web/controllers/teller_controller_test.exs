defmodule HelloWeb.TellerControllerTest do
  use HelloWeb.ConnCase

  import Hello.TellersFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  describe "index" do
    test "lists all tellers", %{conn: conn} do
      conn = get(conn, ~p"/tellers")
      assert html_response(conn, 200) =~ "Listing Tellers"
    end
  end

  describe "new teller" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/tellers/new")
      assert html_response(conn, 200) =~ "New Teller"
    end
  end

  describe "create teller" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/tellers", teller: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/tellers/#{id}"

      conn = get(conn, ~p"/tellers/#{id}")
      assert html_response(conn, 200) =~ "Teller #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/tellers", teller: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Teller"
    end
  end

  describe "edit teller" do
    setup [:create_teller]

    test "renders form for editing chosen teller", %{conn: conn, teller: teller} do
      conn = get(conn, ~p"/tellers/#{teller}/edit")
      assert html_response(conn, 200) =~ "Edit Teller"
    end
  end

  describe "update teller" do
    setup [:create_teller]

    test "redirects when data is valid", %{conn: conn, teller: teller} do
      conn = put(conn, ~p"/tellers/#{teller}", teller: @update_attrs)
      assert redirected_to(conn) == ~p"/tellers/#{teller}"

      conn = get(conn, ~p"/tellers/#{teller}")
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, teller: teller} do
      conn = put(conn, ~p"/tellers/#{teller}", teller: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Teller"
    end
  end

  describe "delete teller" do
    setup [:create_teller]

    test "deletes chosen teller", %{conn: conn, teller: teller} do
      conn = delete(conn, ~p"/tellers/#{teller}")
      assert redirected_to(conn) == ~p"/tellers"

      assert_error_sent 404, fn ->
        get(conn, ~p"/tellers/#{teller}")
      end
    end
  end

  defp create_teller(_) do
    teller = teller_fixture()
    %{teller: teller}
  end
end
