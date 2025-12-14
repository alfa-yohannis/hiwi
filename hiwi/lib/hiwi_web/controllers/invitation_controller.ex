defmodule HiwiWeb.InvitationController do
  use HiwiWeb, :controller

  alias Hiwi.Users
  alias Hiwi.Queues

  @doc """
  Menangani tombol 'Send Invite' dari Dashboard Owner.
  Logika: Cari emailnya -> Kalau ada user-nya -> Langsung jadikan Teller.
  Tanpa kirim email/menunggu konfirmasi (biar tidak error).
  """
  def create(conn, %{"email" => email, "queue_id" => queue_id}) do
    # 1. Cari User berdasarkan Email (Pastikan fungsi get_user_by_email ada di Users context)
    case Users.get_user_by_email(email) do
      %Hiwi.Users.User{} = user ->
        # 2. Cek apakah dia sudah jadi teller di antrean ini?
        if Queues.teller_assigned_to_queue?(queue_id, user.id) do
          conn
          |> put_flash(:error, "User dengan email #{email} SUDAH menjadi teller di sini.")
          |> redirect(to: ~p"/queues")
        else
          # 3. Masukkan sebagai Teller
          Queues.assign_teller_to_queue(queue_id, user.id)

          conn
          |> put_flash(:info, "Sukses! #{email} telah ditambahkan sebagai Teller.")
          |> redirect(to: ~p"/queues")
        end

      nil ->
        # Jika email tidak ditemukan di database
        conn
        |> put_flash(:error, "User dengan email #{email} tidak ditemukan. Pastikan dia sudah Register dulu.")
        |> redirect(to: ~p"/queues")
    end
  end

  # --- Fungsi Dummy (Biar Router Tidak Error) ---
  # Kita biarkan ada tapi kosongkan logic-nya, karena router memanggilnya.
  def show(conn, _params) do
    conn
    |> put_flash(:info, "Fitur ini belum aktif.")
    |> redirect(to: ~p"/")
  end

  def respond(conn, _params) do
    redirect(conn, to: ~p"/")
  end
end
