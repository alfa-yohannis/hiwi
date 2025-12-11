defmodule HiwiWeb.InvitationController do
  use HiwiWeb, :controller
  
  alias Hiwi.Invitations
  alias Hiwi.Repo
  alias Hiwi.Queues.Queue

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
          |> redirect(to: ~p"/queues") # Kembali ke daftar antrian
          
        {:error, :user_not_found} ->
          conn
          |> put_flash(:error, "User dengan email #{email} tidak ditemukan.")
          |> redirect(to: ~p"/queues")

        {:error, :already_teller} ->
          conn
          |> put_flash(:error, "User tersebut sudah menjadi Teller di antrian ini.")
          |> redirect(to: ~p"/queues")

        {:error, _} ->
          conn
          |> put_flash(:error, "Gagal mengirim undangan.")
          |> redirect(to: ~p"/queues")
      end
    else
      conn
      |> put_flash(:error, "Anda tidak memiliki izin.")
      |> redirect(to: ~p"/queues")
    end
  end

  # --- FUNGSI LAMA: Teller Melihat Undangan ---
  def show(conn, %{"token" => token}) do
    current_user = conn.assigns.current_user
    invitation = Invitations.get_invitation_by_token(token)

    if invitation && invitation.invited_user_id == current_user.id do
      render(conn, :show, token: token, invitation: invitation)
    else
      conn
      |> put_flash(:error, "Undangan tidak valid.")
      |> redirect(to: ~p"/")
    end
  end

  # --- FUNGSI LAMA: Teller Merespon Undangan ---
  def respond(conn, %{"token" => token, "decision" => decision}) do
    current_user = conn.assigns.current_user
    
    case Invitations.respond_to_invitation(token, current_user, decision) do
      {:ok, _} ->
        conn |> put_flash(:info, "Respon tersimpan!") |> redirect(to: ~p"/")
      {:error, _} ->
        conn |> put_flash(:error, "Gagal memproses.") |> redirect(to: ~p"/")
    end
  end
end