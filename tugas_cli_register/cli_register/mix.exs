defmodule CliRegister.MixProject do
  use Mix.Project

  def project do
    [
      app: :cli_register,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {CliRegister.Application, []}
    ]
  end

  defp deps do
    [
      {:ecto_sql, "~> 3.13"},
      {:postgrex, ">= 0.0.0"}
    ]
  end
end
