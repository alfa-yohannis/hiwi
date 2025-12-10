# defmodule Hiwi.Queues do
#   @moduledoc """
#   The Queues context.
#   """

#   import Ecto.Query, warn: false
#   alias Hiwi.Repo

#   alias Hiwi.Queues.Queue

#   @doc """
#   Returns the list of queues.

#   ## Examples

#       iex> list_queues()
#       [%Queue{}, ...]

#   """
#   def list_queues do
#     Repo.all(Queue)
#   end

#   @doc """
#   Gets a single queue.

#   Raises `Ecto.NoResultsError` if the Queue does not exist.

#   ## Examples

#       iex> get_queue!(123)
#       %Queue{}

#       iex> get_queue!(456)
#       ** (Ecto.NoResultsError)

#   """
#   def get_queue!(id), do: Repo.get!(Queue, id)

#   @doc """
#   Creates a queue.

#   ## Examples

#       iex> create_queue(%{field: value})
#       {:ok, %Queue{}}

#       iex> create_queue(%{field: bad_value})
#       {:error, %Ecto.Changeset{}}

#   """
#   def create_queue(attrs \\ %{}) do
#     %Queue{}
#     |> Queue.changeset(attrs)
#     |> Repo.insert()
#   end

#   @doc """
#   Updates a queue.

#   ## Examples

#       iex> update_queue(queue, %{field: new_value})
#       {:ok, %Queue{}}

#       iex> update_queue(queue, %{field: bad_value})
#       {:error, %Ecto.Changeset{}}

#   """
#   def update_queue(%Queue{} = queue, attrs) do
#     queue
#     |> Queue.changeset(attrs)
#     |> Repo.update()
#   end

#   @doc """
#   Deletes a queue.

#   ## Examples

#       iex> delete_queue(queue)
#       {:ok, %Queue{}}

#       iex> delete_queue(queue)
#       {:error, %Ecto.Changeset{}}

#   """
#   def delete_queue(%Queue{} = queue) do
#     Repo.delete(queue)
#   end

#   @doc """
#   Returns an `%Ecto.Changeset{}` for tracking queue changes.

#   ## Examples

#       iex> change_queue(queue)
#       %Ecto.Changeset{data: %Queue{}}

#   """
#   def change_queue(%Queue{} = queue, attrs \\ %{}) do
#     Queue.changeset(queue, attrs)
#   end
# end

defmodule Hiwi.Queues do
  alias Hiwi.Repo
  alias Hiwi.Queues.Queue
  alias Hiwi.Users.User # Alias untuk relasi
  alias Ecto.Changeset

  import Ecto.Query, only: [from: 2]

  # --- READ OPERATIONS ---

  @doc """
  Mengembalikan daftar semua antrian, dan memuat owner-nya.
  """
  def list_queues do
    Repo.all(from q in Queue, preload: [:owner])
  end

  @doc """
  Mengambil antrian berdasarkan ID.
  """
  def get_queue!(id) do
    Repo.get!(Queue, id)
    |> Repo.preload(:owner)
  end

  @doc """
  Mengambil antrian berdasarkan prefix yang unik.
  """
  def get_queue_by_prefix(prefix) do
    Repo.get_by(Queue, prefix: prefix)
    |> Repo.preload(:owner)
  end

  # --- WRITE OPERATIONS (CRUD) ---

  @doc """
  Membuat antrian baru.
  Menerima attrs termasuk owner_id.
  Mengembalikan {:ok, queue} atau {:error, changeset}.
  """
  def create_queue(owner_id, attrs) when is_integer(owner_id) do
    attrs_atomized =
      Map.new(attrs, fn
        {k, v} when is_atom(k) -> {k, v}
        {k, v} when is_binary(k) -> {String.to_atom(k), v}
        {k, v} -> {k, v}
      end)


    attrs_with_owner = Map.put(attrs_atomized, :owner_id, owner_id)

    %Queue{}
    |> Queue.changeset(attrs_with_owner)
    |> Repo.insert()
  end

  @doc """
  Memperbarui antrian.
  """
  def update_queue(%Queue{} = queue, attrs) do
    queue
    |> Queue.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Menghapus antrian.
  """
  def delete_queue(%Queue{} = queue) do
    Repo.delete(queue)
  end

  # --- UTILITY & LOGIC ---

  @doc """
  Mengembalikan changeset antrian baru untuk form.
  """
  def build_new_queue_changeset(attrs \\ %{}) do
    %Queue{}
    |> Queue.changeset(attrs)
    # Ini penting agar field current_number = 0 saat form diinisialisasi
    |> Changeset.put_change(:current_number, 0)
  end

  @doc """
  Mereset current_number antrian kembali ke 0.
  """
  def reset_queue(%Queue{} = queue) do
    queue
    |> Changeset.change(%{current_number: 0})
    |> Repo.update()
  end

  @doc """
  Mengambil semua antrian yang dimiliki oleh user tertentu.
  """
  def list_queues_by_owner(owner_id) do
    Repo.all(
      from q in Queue,
      where: q.owner_id == ^owner_id,
      preload: [:owner]
    )
  end
end
