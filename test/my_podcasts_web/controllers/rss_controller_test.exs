defmodule MyPodcastsWeb.RssControllerTest do
  use MyPodcastsWeb.ConnCase

  import MyPodcasts.AccountsFixtures
  import MyPodcasts.FilesFixtures
  import MyPodcasts.CategoriesFixtures

  test "open RSS feed", %{conn: conn} do
    user = user_fixture()
    category = category_fixture(%{user_id: user.id, name: "Programming"})

    file_fixture(%{user_id: user.id, title: "title 1", category_id: category.id})
    file_fixture(%{user_id: user.id, title: "title 2", category_id: category.id})
    file_fixture(%{user_id: user.id, title: "title 2"})

    conn = get(conn, ~p"/rss_feed/#{category.rss_feed}")
    xml = response(conn, 200)

    assert xml =~ "<rss version=\"2.0\""
    assert xml =~ "title 1"
    assert xml =~ "title 2"
    refute xml =~ "title 3"
  end
end
