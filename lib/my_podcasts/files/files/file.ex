defmodule MyPodcasts.Files.File do
  use Ecto.Schema
  import Ecto.Changeset
  alias MyPodcasts.Accounts.User
  alias MyPodcasts.Files.Category

  schema "files" do
    field :description, :string
    field :title, :string
    field :hash, :string
    field :thumbnail, :string
    field :duration, :integer
    belongs_to :category, Category
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(file, attrs) do
    file
    |> cast(attrs, [:title, :description, :hash, :thumbnail, :duration, :user_id, :category_id])
    |> validate_required([:title, :hash, :thumbnail, :duration, :user_id])
  end

  @doc false
  def category_changeset(file, category_id) do
    file
    |> cast(%{category_id: category_id}, [:category_id])
  end
end
