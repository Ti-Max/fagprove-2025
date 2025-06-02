defmodule MyPodcastsWeb.RssXML do
  alias MyPodcasts.Downloader
  use MyPodcastsWeb, :html

  defp file_location(conn, hash),
    do: static_url(conn, Downloader.get_accessible_url(hash))

  embed_templates("rss/*")
end
