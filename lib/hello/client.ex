defmodule Hello.Clients do
  @moduledoc """
  The Clients context.
  """

  import Ecto.Query, warn: false
  alias Hello.Repo

  alias Hello.Clients.Client

  @doc """
  Returns the list of clients.

  ## Examples

      iex> list_clients()
      [%Client{}, ...]

  """
  def list_clients do
    Repo.all(Client)
  end

  @doc """
  Gets a single client.

  Raises `Ecto.NoResultsError` if the Client does not exist.

  ## Examples

      iex> get_client!(123)
      %Client{}

      iex> get_client!(456)
      ** (Ecto.NoResultsError)

  """
  def get_client!(id), do: Repo.get!(Client, id)

  @doc """
  Creates a client.

  ## Examples

      iex> create_client(%{field: value})
      {:ok, %Client{}}

      iex> create_client(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_client(attrs \\ %{}) do
    %Client{}
    |> Client.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a client.

  ## Examples

      iex> update_client(client, %{field: new_value})
      {:ok, %Client{}}

      iex> update_client(client, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_client(%Client{} = client, attrs) do
    client
    |> Client.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a client.

  ## Examples

      iex> delete_client(client)
      {:ok, %Client{}}

      iex> delete_client(client)
      {:error, %Ecto.Changeset{}}

  """
  def delete_client(%Client{} = client) do
    Repo.delete(client)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking client changes.

  ## Examples

      iex> change_client(client)
      %Ecto.Changeset{data: %Client{}}

  """
  def change_client(%Client{} = client, attrs \\ %{}) do
    Client.changeset(client, attrs)
  end

  def create_client_with_queues(attrs, queue_ids) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:client, Client.changeset(%Client{}, attrs))
    |> Ecto.Multi.run(:client_queues, fn _repo, %{client: client} ->
      now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

      queue_joins =
        Enum.map(queue_ids, fn queue_id ->
          %{
            client_id: client.id,
            queue_id: queue_id,
            inserted_at: now,
            updated_at: now
          }
        end)

      {:ok, Repo.insert_all("client_queues", queue_joins)}
    end)
    |> Repo.transaction()
  end

  # Authenticates a client with the provided credentials
  def authenticate_client(email, password) do
    client = Repo.get_by(Client, email: email)

    if client && Argon2.verify_pass(password, client.hashed_password) do
      {:ok, client}
    else
      :error
    end
  end
end
