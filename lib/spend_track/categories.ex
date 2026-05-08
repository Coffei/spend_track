defmodule SpendTrack.Categories do
  @moduledoc """
  The Categories context.
  """

  import Ecto.Query, warn: false
  alias SpendTrack.Repo
  alias SpendTrack.Model.Category
  alias SpendTrack.Model.Payment

  @spec list_categories(integer()) :: [Category.t()]
  def list_categories(user_id) do
    from(c in Category,
      left_join: p in assoc(c, :payments),
      where: c.user_id == ^user_id,
      group_by: c.id,
      select: c,
      select_merge: %{payment_count: coalesce(count(p.id), 0)}
    )
    |> Repo.all()
  end

  @spec count_other_payments(integer()) :: integer()
  def count_other_payments(user_id) do
    from(p in Payment,
      join: a in assoc(p, :account),
      where: a.user_id == ^user_id,
      where: is_nil(p.category_id),
      select: count(p.id)
    )
    |> Repo.one()
  end

  @spec get_category!(integer(), integer()) :: Category.t()
  def get_category!(id, user_id) do
    from(c in Category, where: c.id == ^id and c.user_id == ^user_id)
    |> Repo.one!()
  end

  @spec create_category(integer(), map()) ::
          {:ok, Category.t()} | {:error, Ecto.Changeset.t()}
  def create_category(user_id, attrs \\ %{}) do
    %Category{}
    |> Category.changeset(Map.put(attrs, "user_id", user_id))
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
