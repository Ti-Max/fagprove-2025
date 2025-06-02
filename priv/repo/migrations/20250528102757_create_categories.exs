defmodule MyPodcasts.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string
      add :user_id, references(:users, on_delete: :nothing)
    end

    create index(:categories, [:user_id])
  end
end
