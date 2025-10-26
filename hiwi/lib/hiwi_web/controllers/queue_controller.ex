defmodule HiwiWeb.QueueController do
  use HiwiWeb, :controller

  alias Hiwi.Queues
  alias Hiwi.Queues.Queue

  action_fallback HiwiWeb.FallbackController

  def index(conn, _params) do
    queues = Queues.list_queues()
    render(conn, :index, queues: queues)
  end

  def create(conn, %{"queue" => queue_params}) do
    with {:ok, %Queue{} = queue} <- Queues.create_queue(queue_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/queues/#{queue}")
      |> render(:show, queue: queue)
    end
  end

  def show(conn, %{"id" => id}) do
    queue = Queues.get_queue!(id)
    render(conn, :show, queue: queue)
  end

  def update(conn, %{"id" => id, "queue" => queue_params}) do
    queue = Queues.get_queue!(id)

    with {:ok, %Queue{} = queue} <- Queues.update_queue(queue, queue_params) do
      render(conn, :show, queue: queue)
    end
  end

  def delete(conn, %{"id" => id}) do
    queue = Queues.get_queue!(id)

    with {:ok, %Queue{}} <- Queues.delete_queue(queue) do
      send_resp(conn, :no_content, "")
    end
  end
end
