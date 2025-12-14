defmodule HiwiWeb.InvitationHTML do
  use HiwiWeb, :html

  # Ini memberitahu Phoenix untuk mencari file .heex di folder sebelah
  embed_templates "invitation_html/*"
end