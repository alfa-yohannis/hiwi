defmodule HiwiWeb.InvitationController do
  use HiwiWeb, :controller

  alias Hiwi.Users
  alias Hiwi.Queues
  alias Hiwi.Repo
  import Swoosh.Email

  # Garam rahasia untuk token (bebas)
  @token_salt "undangan_teller_rahasia"

  # 1. SEND INVITE (Kirim Email dengan Token)
  def create(conn, %{"email" => email, "queue_id" => queue_id}) do
    # Konversi ID ke Integer agar DB tidak error
    queue_id_int = String.to_integer(queue_id)
    queue = Queues.get_queue!(queue_id_int)

    # Cek user
    case Users.get_user_by_email(email) do
      nil ->
        conn
        |> put_flash(:error, "Email #{email} belum terdaftar di aplikasi.")
        |> redirect(to: ~p"/queues")

      user ->
        # Cek kalau dia sudah jadi teller
        if Queues.teller_assigned_to_queue?(queue.id, user.id) do
          conn
          |> put_flash(:error, "User ini SUDAH menjadi teller di sini!")
          |> redirect(to: ~p"/queues")
        else
          # A. Buat Token Rahasia (Berlaku 24 Jam)
          token = Phoenix.Token.sign(HiwiWeb.Endpoint, @token_salt, %{queue_id: queue.id, email: email})

          # B. Buat Link Undangan
          url = url(~p"/invitations/#{token}")

          # C. Kirim Email (Masuk Mailbox)
          email_struct =
            new()
            |> to(email)
            |> from({"Hiwi System", "system@hiwi.app"})
            |> subject("Undangan Menjadi Teller: #{queue.name}")
            |> html_body("""
              <h1>Halo!</h1>
              <p>Anda diundang untuk menjadi Teller di antrean: <strong>#{queue.name}</strong>.</p>
              <p>Klik link di bawah ini untuk menerima:</p>
              <a href="#{url}">TERIMA UNDANGAN</a>
              <p><small>Link ini valid selama 24 jam.</small></p>
            """)

          Hiwi.Mailer.deliver(email_struct)

          conn
          |> put_flash(:info, "Undangan terkirim ke Mailbox #{email}!")
          |> redirect(to: ~p"/queues")
        end
    end
  end

  # 2. SHOW PAGE (Halaman Konfirmasi saat link diklik)
  def show(conn, %{"token" => token}) do
    # Verifikasi Token
    case Phoenix.Token.verify(HiwiWeb.Endpoint, @token_salt, token, max_age: 86400) do
      {:ok, %{queue_id: queue_id, email: _email}} ->
        queue = Queues.get_queue!(queue_id)
        # Kirim data @queue dan @token ke HTML
        render(conn, :show, token: token, queue: queue)

      {:error, _} ->
        conn
        |> put_flash(:error, "Link undangan kadaluarsa atau tidak valid.")
        |> redirect(to: ~p"/")
    end
  end

  # 3. RESPOND (Saat tombol 'Terima' diklik)
  def respond(conn, %{"token" => token, "decision" => "accept"}) do
    case Phoenix.Token.verify(HiwiWeb.Endpoint, @token_salt, token, max_age: 86400) do
      {:ok, %{queue_id: queue_id, email: email}} ->
        user = Users.get_user_by_email(email)

        if user do
          # UPDATE ROLE JADI TELLER
          {:ok, user_updated} =
            user
            |> Ecto.Changeset.change(role: :teller)
            |> Repo.update()

          # MASUKKAN KE QUEUE
          Queues.assign_teller_to_queue(queue_id, user_updated.id)

          conn
          |> put_flash(:info, "SELAMAT! Anda resmi menjadi Teller.")
          |> redirect(to: ~p"/queues")
        else
          conn |> put_flash(:error, "User tidak ditemukan.") |> redirect(to: ~p"/")
        end

      {:error, _} ->
        conn |> put_flash(:error, "Token invalid.") |> redirect(to: ~p"/")
    end
  end

  # Kalau user menolak/iseng
  def respond(conn, _params) do
    conn |> put_flash(:info, "Undangan ditolak.") |> redirect(to: ~p"/")
  end
end
