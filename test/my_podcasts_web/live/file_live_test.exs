defmodule MyPodcastsWeb.FileLiveTest do
  alias MyPodcasts.Categories
  alias MyPodcasts.Files
  use MyPodcastsWeb.ConnCase

  import Phoenix.LiveViewTest
  import MyPodcasts.FilesFixtures
  import MyPodcasts.CategoriesFixtures

  describe "All files page" do
    setup :register_and_log_in_user

    test "no downloaded files, show message", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/files")

      assert html =~ "All downloaded files by category"
      assert html =~ "No downloads here yet :("
    end

    test "show 5 downloaded files", %{conn: conn, user: user} do
      for _i <- 1..5 do
        file_fixture(%{user_id: user.id, title: "super title"})
      end

      {:ok, _index_live, html} = live(conn, ~p"/files")

      assert files_count(html) == 5

      assert html =~ "super title"
    end

    test "5 files downloaded, but only 2 are in the current category", %{conn: conn, user: user} do
      category = category_fixture(%{user_id: user.id, name: "asdf"})

      for _i <- 1..2 do
        file_fixture(%{user_id: user.id, title: "super title", category_id: category.id})
      end

      for _i <- 1..3 do
        file_fixture(%{user_id: user.id, title: "super title"})
      end

      {:ok, view, html} = live(conn, ~p"/files?category=asdf")

      assert files_count(html) == 2

      assert render_patch(view, ~p"/files")
             |> files_count() == 5
    end

    test "delete file", %{conn: conn, user: user} do
      [file | _tail] =
        for _i <- 1..5 do
          file_fixture(%{user_id: user.id, title: "super title"})
        end

      {:ok, view, html} = live(conn, ~p"/files")

      assert files_count(html) == 5

      view
      |> element("#delete-#{file.id}")
      |> render_click()

      assert render_patch(view, ~p"/files")
             |> files_count() == 4

      assert Files.get_by_user_id(user.id) |> length() == 4
    end

    test "add a new category and change ", %{conn: conn, user: user} do
      category = category_fixture(%{user_id: user.id, name: "Gaming"})

      [file | _tail] =
        for _i <- 1..5 do
          file_fixture(%{user_id: user.id, title: "super title", category_id: category.id})
        end

      {:ok, view, html} = live(conn, ~p"/files?category=Gaming")

      assert files_count(html) == 5

      assert view
             |> element("#edit-#{file.id}")
             |> render_click() =~
               "Adding the file to a category automatically includes it in the RSS feed"

      add_new_category(view, "asdf")

      # select new category
      category = Categories.get_by_user_and_name(user.id, "asdf")

      view
      |> form("#category-form", %{category_id: category.id})
      |> render_submit()

      # one less in the Gaming category
      assert view |> render() |> files_count() == 4

      # file is updated in the database
      file = Files.get_file!(file.id)
      assert file.category_id == category.id
    end
  end

  defp files_count(html) do
    html
    |> Floki.parse_fragment!()
    |> Floki.get_by_id("files-table")
    |> Floki.children()
    |> length()
  end

  defp add_new_category(view, name) do
    view
    |> element("#add-new-category")
    |> render_click()

    view
    |> form("#new-category-form", category: %{name: name})
    |> render_submit()
  end
end
