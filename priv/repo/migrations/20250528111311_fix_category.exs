defmodule MyPodcasts.Repo.Migrations.FixCategory do
  use Ecto.Migration

  def change do
    alter table(:files) do
      remove :category
      add :category_id, references(:categories, on_delete: :nothing)
    end
  end
end
