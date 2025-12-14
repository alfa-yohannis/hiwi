defmodule Hiwi.Queues do
    alias Hiwi.Repo
    alias Hiwi.Queues.Queue

    alias Ecto.Changeset

    import Ecto.Query, only: [from: 2]

    @doc """
    Mengembalikan daftar semua antrian, dan memuat owner-nya.
    """
    def list_queues do
        Repo.all(from q in Queue, preload: [:owner])
    end

    @doc """
    Mengembalikan daftar semua antrian yang aktif
    """
    def list_active_queues do
        from(q in Queue, where: q.status == :active)
        |> Repo.all()
    end

    @doc """
    Mengambil antrian berdasarkan ID.
    """
    def get_queue!(id) do
        Repo.get!(Queue, id)
        |> Repo.preload(:owner)
    end

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

    def build_edit_queue_changeset(queue, attrs \\ %{}) do
        Queue.changeset(queue, attrs)
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

    @doc """
    Menambahkan seorang teller ke antrian tertentu jika belum terdaftar.
    Jika teller sudah ada di antrian, tidak akan menambahkan duplikat.
    """
    def assign_teller_to_queue(queue_id, user_id) do
        queue =
            Repo.get!(Queue, queue_id)
            |> Repo.preload(:tellers)

        user  = Repo.get!(Hiwi.Users.User, user_id)

        tellers =
            if Enum.any?(queue.tellers, fn t -> t.id == user_id end) do
                queue.tellers
            else
                queue.tellers ++ [user]
            end

        queue
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.put_assoc(:tellers, tellers)
        |> Repo.update()
    end

    @doc """
    Menghapus seorang teller dari antrian tertentu.
    """
    def remove_teller_from_queue(queue_id, user_id) do
        queue =
            Repo.get!(Queue, queue_id)
            |> Repo.preload(:tellers)

        updated = Enum.reject(queue.tellers, fn t -> t.id == user_id end)

        queue
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.put_assoc(:tellers, updated)
        |> Repo.update()
    end

    @doc """
    Mengambil daftar semua teller yang terdaftar pada antrian tertentu.
    """
    def list_tellers_for_queue(queue_id) do
        Repo.get!(Queue, queue_id)
        |> Repo.preload(:tellers)
        |> Map.get(:tellers)
    end

    @doc """
    Memeriksa apakah seorang user sudah menjadi teller pada antrian tertentu.
    """
    def teller_assigned_to_queue?(queue_id, user_id) do
        query =
        from(qt in "queue_tellers",
            where: qt.queue_id == ^queue_id and qt.user_id == ^user_id,
            select: count(qt.user_id)
        )

        Repo.one(query) > 0
    end
end
