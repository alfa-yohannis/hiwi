defmodule Hiwi.Users do
  import Ecto.Query, warn: false

  alias Hiwi.Repo
  alias Hiwi.Users.User

  def register_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def build_registration_changeset() do
    User.registration_changeset(%User{}, %{})
  end

  def build_login_changeset() do
    User.login_changeset(%User{}, %{})
  end

  def authenticate_user(email, password) do
    user = Repo.get_by(User, email: email)

    cond do
      user && Pbkdf2.verify_pass(password, user.hashed_password) ->
        {:ok, user}

      user ->
        {:error, :unauthorized}

      true ->
        Pbkdf2.no_user_verify()
        {:error, :not_found}
    end
  end

  # --- TAMBAHAN UNTUK FITUR UNDANGAN ---
  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Register user via OAuth (Google).

  - Auto set role default dari schema (:client)
  - Password random (tidak dipakai untuk OAuth)
  """
  def register_oauth_user(attrs) do
    random_password = Ecto.UUID.generate()

    %User{}
    |> User.registration_changeset(%{
      "fullname" => attrs["fullname"],
      "email" => attrs["email"],
      "password" => random_password
    })
    |> Repo.insert()
  end

  @doc """
  Mengambil daftar semua teller (users) yang belum di assign pada antrian tertentu.
  """
  def list_tellers_not_assigned_to(queue_id) do
    import Ecto.Query, only: [from: 2]

    from(u in User,
      left_join: qt in "queue_tellers",
      on: qt.user_id == u.id and qt.queue_id == ^queue_id,
      where: u.role == ^:teller,
      where: is_nil(qt.user_id),
      select: u
    )
    |> Repo.all()
  end
end
