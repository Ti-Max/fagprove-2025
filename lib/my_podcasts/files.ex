defmodule MyPodcasts.Files do
  @moduledoc """
  The Files context.
  """

  import Ecto.Query, warn: false
  alias MyPodcasts.Repo

  alias MyPodcasts.Files.File

  @doc """
  Returns the list of files by the user
  """
  def get_by_user_id(user_id) do
    File
    |> where(user_id: ^user_id)
    |> Repo.all()
  end

  @doc """
  Returns the file by it's hash
  """
  def get_by_hash(file_hash) do
    File
    |> Repo.get_by(hash: file_hash)
  end

  @doc """
  Returns the list of files by the category.
  """
  def get_by_user_and_category(user_id, category_id) do
    File
    |> where(user_id: ^user_id, category_id: ^category_id)
    |> Repo.all()
  end

  @doc """
  Gets a single file.

  Raises `Ecto.NoResultsError` if the File does not exist.
  """
  def get_file!(id), do: Repo.get!(File, id)

  @doc """
  Gets a single file, scoped by the user
  """
  def get_file(id, user_id), do: Repo.get_by(File, id: id, user_id: user_id)

  @doc """
  Creates a file.

  ## Examples

      iex> create_file(%{field: value})
      {:ok, %File{}}

      iex> create_file(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_file(attrs \\ %{}) do
    %File{}
    |> File.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a file.

  ## Examples

      iex> update_file(file, %{field: new_value})
      {:ok, %File{}}

      iex> update_file(file, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_file(%File{} = file, attrs) do
    file
    |> File.changeset(attrs)
    |> Repo.update()
  end
   
  @doc """
  Update a category of the file
  """
  def update_category(%File{} = file, category_id) do
    file
    |> File.category_changeset(category_id)
    |> Repo.update()
  end

  @doc """
  Deletes a file.

  ## Examples

      iex> delete_file(file)
      {:ok, %File{}}

      iex> delete_file(file)
      {:error, %Ecto.Changeset{}}

  """
  def delete_file(%File{} = file) do
    Repo.delete(file)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking file changes.

  ## Examples

      iex> change_file(file)
      %Ecto.Changeset{data: %File{}}

  """
  def change_file(%File{} = file, attrs \\ %{}) do
    File.changeset(file, attrs)
  end
end
