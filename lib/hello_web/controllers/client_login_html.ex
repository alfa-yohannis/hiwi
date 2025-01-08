defmodule HelloWeb.ClientLoginHTML do
  use HelloWeb, :html

  # This ensures Phoenix looks for templates in the "login_html" folder
  embed_templates "client_login/*"
end
