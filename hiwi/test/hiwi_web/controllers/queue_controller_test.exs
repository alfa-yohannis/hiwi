defmodule HiwiWeb.QueueControllerTest do
  use HiwiWeb.ConnCase

  import Hiwi.QueuesFixtures

  alias Hiwi.Queues.Queue

  @create_attrs %{
    name: "some name",
    status: "some status",
    description: "some description",
    prefix: "some prefix",
    max_number: 42,
    current_number: 42
  }
  @update_attrs %{
    name: "some updated name",
    status: "some updated status",
    description: "some updated description",
    prefix: "some updated prefix",
    max_number: 43,
    current_number: 43
  }
  @invalid_attrs %{name: nil, status: nil, description: nil, prefix: nil, max_number: nil, current_number: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all queues", %{conn: conn} do
      conn = get(conn, ~p"/api/queues")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create queue" do
    test "renders queue when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/queues", queue: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/queues/#{id}")

      assert %{
               "id" => ^id,
               "current_number" => 42,
               "description" => "some description",
               "max_number" => 42,
               "name" => "some name",
               "prefix" => "some prefix",
               "status" => "some status"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/queues", queue: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update queue" do
    setup [:create_queue]

    test "renders queue when data is valid", %{conn: conn, queue: %Queue{id: id} = queue} do
      conn = put(conn, ~p"/api/queues/#{queue}", queue: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/queues/#{id}")

      assert %{
               "id" => ^id,
               "current_number" => 43,
               "description" => "some updated description",
               "max_number" => 43,
               "name" => "some updated name",
               "prefix" => "some updated prefix",
               "status" => "some updated status"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, queue: queue} do
      conn = put(conn, ~p"/api/queues/#{queue}", queue: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete queue" do
    setup [:create_queue]

    test "deletes chosen queue", %{conn: conn, queue: queue} do
      conn = delete(conn, ~p"/api/queues/#{queue}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/queues/#{queue}")
      end
    end
  end

  defp create_queue(_) do
    queue = queue_fixture()
    %{queue: queue}
  end
end
