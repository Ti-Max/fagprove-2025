defmodule MyPodcasts.CategoriesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MyPodcasts.Categories` context.
  """

  @doc """
  Generate a category.
  """
  def category_fixture(attrs \\ %{}) do
    {:ok, category} =
      attrs
      |> Enum.into(%{
        name: "category name",
        rss_feed: "rss feed",
      })
      |> MyPodcasts.Categories.create_category()

    category
  end
end
