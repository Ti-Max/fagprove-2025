defmodule MyPodcasts.Repo.Migrations.NilifyCategoryIdOnDelete do
  use Ecto.Migration

  def change do
    alter table(:files) do
      remove :category_id
      add :category_id, references(:categories, on_delete: :nilify_all)
    end
  end
end
