defmodule MyPodcasts.Files.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field(:name, :string)
    field(:rss_feed, :string)
    belongs_to(:user, MyPodcasts.Accounts.User)
  end

  @doc false
  def changeset(attrs) do
    changeset(%__MODULE__{}, attrs)
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :user_id, :rss_feed])
    |> validate_required([:name, :user_id])
    |> then(fn cs ->
      validate_unique_name(cs)
    end)
  end

  defp validate_unique_name(cs) do
    cs
    |> validate_change(:name, fn :name, name ->
      category = MyPodcasts.Categories.get_by_user_and_name(cs.changes.user_id, name)

      if category do
        [name: "Name of categories must be unique"]
      else
        []
      end
    end)
  end
end
