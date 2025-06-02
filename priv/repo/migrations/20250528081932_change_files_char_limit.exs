defmodule MyPodcasts.Repo.Migrations.ChangeFilesCharLimit do
  use Ecto.Migration

  def change do
    alter table(:files) do
      remove :description
      add :description, :text
    end
  end
end
