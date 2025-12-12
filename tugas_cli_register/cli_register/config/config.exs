import Config

# Daftarkan Repo
config :cli_register, ecto_repos: [CliRegister.Repo]

# Konfigurasi database PostgreSQL
config :cli_register, CliRegister.Repo,
  database: "cli_register_dev",
  username: "postgres",
  password: "1234",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
