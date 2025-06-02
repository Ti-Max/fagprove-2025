defmodule MyPodcasts.Repo.Migrations.CreateFiles do
  use Ecto.Migration

  def change do
    create table(:files) do
      add :title, :string
      add :description, :string
      add :url, :string
      add :thumbnail, :string
      add :duration, :integer
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:files, [:user_id])
  end
end
