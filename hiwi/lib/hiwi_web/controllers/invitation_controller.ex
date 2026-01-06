# lib/hiwi_web/controllers/invitation_controller.ex

defmodule HiwiWeb.InvitationController do
  use HiwiWeb, :controller
  
  alias Hiwi.Invitations
  alias Hiwi.Repo
  alias Hiwi.Queues.Queue
  
  # Plug untuk memastikan hanya user yang login yang bisa mengakses fungsi ini
  plug(
    HiwiWeb.Plugs.RequireAuth
    when action in [:show, :respond]
  )

  # --- FUNGSI BARU: Owner Mengirim Undangan ---
  def create(conn, %{"queue_id" => queue_id, "email" => email}) do
    owner = conn.assigns.current_user
    queue = Repo.get(Queue, queue_id)

    # Validasi: Pastikan Antrian ada DAN Owner-nya adalah user yang sedang login
    if queue && queue.owner_id == owner.id do
      case Invitations.invite_teller(queue, owner, email) do
        {:ok, _invitation} ->
          conn
          |> put_flash(:info, "Undangan berhasil dikirim ke #{email}!")
          |> redirect(to: ~p"/queues")
          
        {:error, :user_not_found} ->
          conn
          |> put_flash(:error, "User dengan email #{email} tidak ditemukan.")
          |> redirect(to: ~p"/queues")

        {:error, :cannot_invite_self} ->
          conn
          |> put_flash(:error, "Anda tidak dapat mengundang diri Anda sendiri.")
          |> redirect(to: ~p"/queues")

        {:error, :already_teller} ->
          conn
          |> put_flash(:error, "User tersebut sudah menjadi Teller di antrian ini.")
          |> redirect(to: ~p"/queues")

        {:error, _} ->
          conn
          |> put_flash(:error, "Gagal mengirim undangan. Pastikan data valid.")
          |> redirect(to: ~p"/queues")
      end
    else
      conn
      |> put_flash(:error, "Anda tidak memiliki izin untuk mengundang Teller untuk antrian ini.")
      |> redirect(to: ~p"/queues")
    end
  end

  # --- FUNGSI TELER MELIHAT UNDANGAN ---
  def show(conn, %{"token" => token}) do
    current_user = conn.assigns.current_user
    invitation = Invitations.get_invitation_by_token(token)

    # Validasi: Undangan ditemukan, dan ditujukan untuk user yang sedang login, dan status masih pending
    if invitation && invitation.invited_user_id == current_user.id && invitation.status == "pending" do
      # Melewati @invitation ke view
      render(conn, :show, invitation: invitation)
    else
      # Jika tidak valid (tidak ditemukan, bukan untuk user, atau sudah direspon)
      conn
      |> put_flash(:error, "Undangan tidak valid atau sudah direspon.")
      |> redirect(to: ~p"/queues") # Redirect ke halaman daftar antrian
    end
  end

  # --- FUNGSI TELER MERESPON UNDANGAN ---
  # Menggunakan POST request karena mengubah state
  def respond(conn, %{"token" => token, "decision" => decision}) do
    current_user = conn.assigns[:current_user]
    
    # decision harus berupa string "accepted" atau "declined"
    if decision not in ["accepted", "declined"] do
      # Perbaikan: Langsung return hasil pipe, tanpa kata kunci 'return'
      conn
      |> put_flash(:error, "Keputusan tidak valid.")
      |> redirect(to: ~p"/queues")
    else
      case Invitations.respond_to_invitation(token, current_user, decision) do
        # Sukses
        {:ok, _} when decision == "accepted" ->
          conn 
          |> put_flash(:info, "Selamat! Anda resmi menjadi Teller.") 
          |> redirect(to: ~p"/queues")

        {:ok, _} when decision == "declined" ->
          conn 
          |> put_flash(:info, "Anda telah menolak undangan tersebut.") 
          |> redirect(to: ~p"/queues")

        # Error (contoh error handling yang lebih baik)
        {:error, :not_found} -> 
          conn |> put_flash(:error, "Undangan tidak ditemukan.") |> redirect(to: ~p"/queues")
        {:error, :forbidden} -> 
          conn |> put_flash(:error, "Undangan ini bukan untuk Anda.") |> redirect(to: ~p"/queues")
        {:error, :already_responded} ->
          conn |> put_flash(:error, "Undangan sudah pernah direspon.") |> redirect(to: ~p"/queues")
        {:error, _} ->
          conn |> put_flash(:error, "Gagal memproses respon Anda.") |> redirect(to: ~p"/queues")
      end
    end
  end
end