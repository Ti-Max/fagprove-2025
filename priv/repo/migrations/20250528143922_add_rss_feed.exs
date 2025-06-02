defmodule MyPodcasts.Repo.Migrations.AddRssFeed do
  use Ecto.Migration

  def change do
    alter table(:categories) do
      add :rss_feed, :string
    end

    alter table(:users) do
      add :rss_feed, :string
    end
  end
end
