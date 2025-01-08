defmodule HelloWeb.ClientRegisterHTML do
  use HelloWeb, :html

  # This ensures Phoenix looks for templates in the "login_html" folder
  embed_templates "client_register/*"
end
