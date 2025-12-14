defmodule Hiwi.Accounts.UserNotifier do
  import Swoosh.Email

  alias Hiwi.Mailer

  # --- FUNGSI PENGIRIM EMAIL UNDANGAN (YANG KITA BUTUHKAN) ---
  def deliver_invitation_instructions(invitation, email) do
    deliver(email, "Undangan Menjadi Teller", """
    Halo!

    Kamu telah diundang untuk menjadi Teller di aplikasi Hiwi.

    Silakan klik link di bawah ini untuk menerima undangan dan bergabung:
    #{HiwiWeb.Endpoint.url()}/invitations/#{invitation.token}

    Jika kamu tidak merasa meminta ini, abaikan saja email ini.
    """)
  end

  # --- FUNGSI STANDAR BAWAAN GEN.AUTH (BIAR GA ERROR KALAU DIPANGGIL) ---
  def deliver_confirmation_instructions(user, url) do
    deliver(user.email, "Confirmation instructions", """
    ==============================
    Hi #{user.email},

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.
    ==============================
    """)
  end

  def deliver_reset_password_instructions(user, url) do
    deliver(user.email, "Reset password instructions", """
    ==============================
    Hi #{user.email},

    You can reset your password by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.
    ==============================
    """)
  end

  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "Update email instructions", """
    ==============================
    Hi #{user.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.
    ==============================
    """)
  end

  # Fungsi Helper untuk mengirim email
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"Hiwi", "contact@example.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end
end
