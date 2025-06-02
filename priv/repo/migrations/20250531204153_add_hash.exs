defmodule MyPodcasts.Repo.Migrations.AddHash do
  use Ecto.Migration

  def change do
    alter table(:files) do
      remove :url
      add :hash, :string
    end
  end
end
