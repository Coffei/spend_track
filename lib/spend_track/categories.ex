defmodule SpendTrack.Categories do
  @moduledoc """
  The Categories context.
  """

  import Ecto.Query, warn: false
  alias SpendTrack.Repo
  alias SpendTrack.Model.Category

  @spec list_categories() :: [Category.t()]
  def list_categories do
    Repo.all(Category)
  end

  @spec get_category!(integer()) :: Category.t()
  def get_category!(id), do: Repo.get!(Category, id)

  @spec create_category(map()) :: {:ok, Category.t()} | {:error, Ecto.Changeset.t()}
  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_category(Category.t(), map()) :: {:ok, Category.t()} | {:error, Ecto.Changeset.t()}
  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  @spec delete_category(Category.t()) :: {:ok, Category.t()} | {:error, Ecto.Changeset.t()}
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  @spec change_category(Category.t(), map()) :: Ecto.Changeset.t()
  def change_category(%Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end
end
