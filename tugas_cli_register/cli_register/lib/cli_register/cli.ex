defmodule CliRegister.CLI do
  alias CliRegister.{Repo, Client}

  def start do
    IO.puts("=== CLI REGISTER ===")
    menu()
  end

  defp menu do
    IO.puts("""
    Menu:
    1. Register Client (manual)
    2. Register Client via Barcode
    3. Show All Clients
    4. Exit
    """)

    choice = IO.gets("Choose an option: ") |> String.trim()

    case choice do
      "1" -> register_client_manual()
      "2" -> register_client_barcode()
      "3" -> show_clients()
      "4" -> IO.puts("Goodbye!")
      _ -> IO.puts("Invalid choice."); menu()
    end
  end

  # -------------------------
  # REGISTER MANUAL
  # -------------------------
  defp register_client_manual do
    name = IO.gets("Enter client name: ") |> String.trim()
    queue_id = IO.gets("Enter Queue ID / Barcode: ") |> String.trim()
    register_client(name, queue_id)
    menu()
  end

  # -------------------------
  # REGISTER VIA BARCODE
  # -------------------------
  defp register_client_barcode do
    IO.puts("Enter path to barcode image:")
    path = IO.gets("") |> String.trim()

    {output, status} =
      System.cmd("C:\\Program Files (x86)\\ZBar\\bin\\zbarimg.exe", [path])

    if status == 0 do
      # contoh output: "QR-Code:12345"
      [_, code] = String.split(output, ":")
      code = String.trim(code)

      IO.puts("Scanned Queue ID: #{code}")

      IO.puts("Enter client name:")
      name = IO.gets("") |> String.trim()

      register_client(name, code)

      IO.puts("Client registered successfully!")
    else
      IO.puts("Failed to read barcode. Check file path.")
    end

    menu()
  end

  # -------------------------
  # SAVE TO DATABASE
  # -------------------------
  defp register_client(name, queue_id) do
    %Client{name: String.upcase(name), queue_id: queue_id}
    |> Repo.insert()
  end

  # -------------------------
  # SHOW ALL CLIENTS
  # -------------------------
  defp show_clients do
    Repo.all(Client)
    |> Enum.each(fn c ->
      IO.puts("#{c.name} - #{c.queue_id}")
    end)

    menu()
  end
end
