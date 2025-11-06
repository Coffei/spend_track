defmodule SpendTrack.Users do
  @moduledoc """
  Users context for authentication and lookup.
  """

  import Ecto.Query, warn: false
  alias SpendTrack.Repo
  alias SpendTrack.Model.User

  @spec get_user!(integer()) :: User.t()
  def get_user!(id), do: Repo.get!(User, id)

  @spec get_user_by_provider_uid(String.t(), String.t()) :: User.t() | nil
  def get_user_by_provider_uid(provider, uid) do
    Repo.get_by(User, provider: provider, uid: uid)
  end

  @spec get_user_by_email(String.t()) :: User.t() | nil
  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  @spec create_user(map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_user(User.t(), map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Create or update a user from Ueberauth.Auth struct.
  """
  @spec create_or_update_from_auth(Ueberauth.Auth.t()) :: {:ok, User.t()} | {:error, term()}
  def create_or_update_from_auth(%Ueberauth.Auth{} = auth) do
    provider = to_string(auth.provider)
    uid = to_string(auth.uid)
    email = auth.info.email
    name = auth.info.name
    avatar_url = auth.info.image

    case get_user_by_provider_uid(provider, uid) || (email && get_user_by_email(email)) do
      %User{} = user ->
        update_user(user, %{
          name: name,
          email: email,
          avatar_url: avatar_url,
          provider: provider,
          uid: uid
        })

      nil ->
        create_user(%{
          name: name,
          email: email,
          avatar_url: avatar_url,
          provider: provider,
          uid: uid
        })
    end
  end
end
