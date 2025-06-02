defmodule MyPodcasts.Categories do
  @moduledoc """
  The Categories context.
  """

  import Ecto.Query, warn: false
  alias MyPodcasts.Repo

  alias MyPodcasts.Files.Category

  @doc """
  Returns a category by its name and user id.
  """
  def get_by_user_and_name(user_id, category_name) do
    Category
    |> Repo.get_by(user_id: user_id, name: category_name)
  end

  @doc """
  Returns the list of categories by user.
  """
  def get_by_user_id(user_id) do
    Category
    |> where(user_id: ^user_id)
    |> Repo.all()
  end

  @doc """
  Returns a category by rss feed
  """
  def get_by_rss_feed(feed_hash) do
    Category
    |> Repo.get_by(rss_feed: feed_hash)
  end

  @doc """
  Creates a category.
  """
  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a category.
  """
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  @doc """
  Updates a category.
  """
  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end
end
