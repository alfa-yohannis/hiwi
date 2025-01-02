defmodule HelloWeb.TellerHTML do
  use HelloWeb, :html

  embed_templates "teller_html/*"

  @doc """
  Renders a teller form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def teller_form(assigns)
end
