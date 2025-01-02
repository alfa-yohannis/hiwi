defmodule Hello.Tellers do
  @moduledoc """
  The Tellers context.
  """

  import Ecto.Query, warn: false
  alias Hello.Repo

  alias Hello.Tellers.Teller

  @doc """
  Returns the list of tellers.

  ## Examples

      iex> list_tellers()
      [%Teller{}, ...]

  """
  def list_tellers do
    Repo.all(Teller)
  end

  @doc """
  Gets a single teller.

  Raises `Ecto.NoResultsError` if the Teller does not exist.

  ## Examples

      iex> get_teller!(123)
      %Teller{}

      iex> get_teller!(456)
      ** (Ecto.NoResultsError)

  """
  def get_teller!(id), do: Repo.get!(Teller, id)

  @doc """
  Creates a teller.

  ## Examples

      iex> create_teller(%{field: value})
      {:ok, %Teller{}}

      iex> create_teller(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_teller(attrs \\ %{}) do
    %Teller{}
    |> Teller.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a teller.

  ## Examples

      iex> update_teller(teller, %{field: new_value})
      {:ok, %Teller{}}

      iex> update_teller(teller, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_teller(%Teller{} = teller, attrs) do
    teller
    |> Teller.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a teller.

  ## Examples

      iex> delete_teller(teller)
      {:ok, %Teller{}}

      iex> delete_teller(teller)
      {:error, %Ecto.Changeset{}}

  """
  def delete_teller(%Teller{} = teller) do
    Repo.delete(teller)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking teller changes.

  ## Examples

      iex> change_teller(teller)
      %Ecto.Changeset{data: %Teller{}}

  """
  def change_teller(%Teller{} = teller, attrs \\ %{}) do
    Teller.changeset(teller, attrs)
  end

  def create_teller_with_queues(attrs, queue_ids) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:teller, Teller.changeset(%Teller{}, attrs))
    |> Ecto.Multi.run(:teller_queues, fn _repo, %{teller: teller} ->
      now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

      queue_joins =
        Enum.map(queue_ids, fn queue_id ->
          %{
            teller_id: teller.id,
            queue_id: queue_id,
            inserted_at: now,
            updated_at: now
          }
        end)

      {:ok, Repo.insert_all("teller_queues", queue_joins)}
    end)
    |> Repo.transaction()
  end
end
