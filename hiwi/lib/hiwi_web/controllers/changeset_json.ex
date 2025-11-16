defmodule HiwiWeb.ChangesetJSON do
  @doc """
  Renders changeset errors.
  (Ini file yang hilang yang menyebabkan error terakhir)
  """

  # Ini dipanggil oleh render(ChangesetJSON, :error, ...)
  # Tugasnya adalah mengubah error Ecto menjadi JSON
  def error(%{changeset: changeset}) do
    %{errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)}
  end

  # Fungsi helper untuk mengubah error Ecto menjadi pesan string
  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end
end