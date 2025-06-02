defmodule MyPodcasts.FilesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MyPodcasts.Files` context.
  """

  @doc """
  Generate a file.
  """
  def file_fixture(attrs \\ %{}) do
    {:ok, file} =
      attrs
      |> Enum.into(%{
        description: "some description",
        duration: 99,
        thumbnail: "some thumbnail",
        title: "some title",
        hash: "some hash"
      })
      |> MyPodcasts.Files.create_file()

    file
  end
end
