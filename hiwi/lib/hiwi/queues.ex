defmodule Hiwi.Queues do
  import Ecto.Query, warn: false

  alias Hiwi.Repo
  alias Hiwi.Queues.Queue
  alias Hiwi.Users.User

  # =========================
  # LIST & GET
  # =========================

  def list_active_queues do
    Queue
    |> where([q], q.status == :active)
    |> order_by([q], asc: q.id)
    |> Repo.all()
    |> Repo.preload([:tellers, :owner])
  end

  def list_queues_by_owner(owner_id) do
    Queue
    |> where([q], q.owner_id == ^owner_id)
    |> order_by([q], asc: q.id)
    |> Repo.all()
    |> Repo.preload([:tellers, :owner])
  end

  def get_queue!(id) do
    Queue
    |> Repo.get!(id)
    |> Repo.preload([:tellers, :owner])
  end

  # =========================
  # CREATE / UPDATE / DELETE
  # =========================

  def build_new_queue_changeset do
    Queue.changeset(%Queue{}, %{})
  end

  def create_queue(owner_id, attrs) do
    attrs = Map.put(attrs, "owner_id", owner_id)

    %Queue{}
    |> Queue.changeset(attrs)
    |> Repo.insert()
  end

  def build_edit_queue_changeset(%Queue{} = queue) do
    Queue.changeset(queue, %{})
  end

  def update_queue(%Queue{} = queue, attrs) do
    queue
    |> Queue.changeset(attrs)
    |> Repo.update()
  end

  def delete_queue(%Queue{} = queue) do
    Repo.delete(queue)
  end

  # =========================
  # ASSIGN / REMOVE TELLER
  # (dipakai oleh QueueController)
  # =========================

  def assign_teller_to_queue(queue_id, user_id) do
    queue =
      Queue
      |> Repo.get!(queue_id)
      |> Repo.preload(:tellers)

    user = Repo.get!(User, user_id)

    # kalau user bukan teller, tolak
    if user.role != :teller do
      {:error, :not_teller}
    else
      # kalau sudah ada, tidak perlu dobel
      if Enum.any?(queue.tellers, &(&1.id == user.id)) do
        {:ok, queue}
      else
        queue
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.put_assoc(:tellers, [user | queue.tellers])
        |> Repo.update()
      end
    end
  end

  def remove_teller_from_queue(queue_id, user_id) do
    queue =
      Queue
      |> Repo.get!(queue_id)
      |> Repo.preload(:tellers)

    new_tellers = Enum.reject(queue.tellers, &(&1.id == user_id))

    queue
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:tellers, new_tellers)
    |> Repo.update()
  end

  # =========================
  # TEL-INCREMENT (JOB WAHYU)
  # =========================

  @doc """
  Teller increment current_number pada queue yang memang ditugaskan ke teller tsb.

  Rules:
  - Queue harus :active
  - Teller harus termasuk di queue.tellers
  - current_number tidak boleh lewat max_number
  """
  def increment_queue(queue_id, %User{} = teller) do
    queue =
      Queue
      |> Repo.get!(queue_id)
      |> Repo.preload(:tellers)

    teller_ids = Enum.map(queue.tellers, & &1.id)

    cond do
      queue.status != :active ->
        {:error, :inactive}

      teller.id not in teller_ids ->
        {:error, :unauthorized}

      queue.current_number >= queue.max_number ->
        {:error, :max_reached}

      true ->
        queue
        |> Ecto.Changeset.change(current_number: queue.current_number + 1)
        |> Repo.update()
        
    end
  end

    # =========================
  # OWN-INCREMENT
  # =========================

  @doc """
  Owner increment current_number pada queue miliknya sendiri.

  Rules:
  - Queue harus :active
  - Owner harus pemilik queue
  - current_number tidak boleh lewat max_number
  """
  def increment_queue_by_owner(queue_id, %User{} = owner) do
    queue = Repo.get!(Queue, queue_id)

    cond do
      queue.owner_id != owner.id ->
        {:error, :unauthorized}

      queue.status != :active ->
        {:error, :inactive}

      queue.current_number >= queue.max_number ->
        {:error, :max_reached}

      true ->
        queue
        |> Ecto.Changeset.change(current_number: queue.current_number + 1)
        |> Repo.update()
    end
  end

end
