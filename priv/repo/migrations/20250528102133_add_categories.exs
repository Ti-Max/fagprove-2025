defmodule MyPodcasts.Repo.Migrations.AddCategories do
  use Ecto.Migration

  def change do
    alter table(:files) do
      add :category, :string
    end
  end
end
