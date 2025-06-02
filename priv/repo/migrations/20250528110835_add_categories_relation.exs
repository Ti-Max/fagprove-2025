defmodule MyPodcasts.Repo.Migrations.AddCategoriesRelation do
  use Ecto.Migration

  def change do
    alter table(:files) do
      remove :category
      add :category, references(:categories, on_delete: :nothing)
    end
  end
end
