defmodule MyPodcastsWeb.RssController do
  alias MyPodcasts.Categories
  alias MyPodcasts.Files
  use MyPodcastsWeb, :controller

  def index(conn, %{"feed_hash" => feed_hash}) do
    case Categories.get_by_rss_feed(feed_hash) do
      nil ->
        conn
        |> Plug.Conn.send_resp(404, "Not Found")

      category ->
        files = Files.get_by_user_and_category(category.user_id, category.id)

        conn
        |> put_resp_content_type("application/rss+xml")
        |> render("index.xml", files: files, category_name: category.name)
    end
  end
end
