defmodule ClientRegistrationWeb.ClientControllerTest do
  use ClientRegistrationWeb.ConnCase

  import ClientRegistration.AccountsFixtures

  @create_attrs %{name: "some name", email: "some email", phone: "some phone"}
  @update_attrs %{name: "some updated name", email: "some updated email", phone: "some updated phone"}
  @invalid_attrs %{name: nil, email: nil, phone: nil}

  describe "new client" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/clients/new")
      assert html_response(conn, 200) =~ "New Client"
    end
  end

  describe "create client" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/clients", client: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/clients/#{id}"

      conn = get(conn, ~p"/clients/#{id}")
      assert html_response(conn, 200) =~ "Client #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/clients", client: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Client"
    end
  end

  defp create_client(_) do
    client = client_fixture()
    %{client: client}
  end
end
