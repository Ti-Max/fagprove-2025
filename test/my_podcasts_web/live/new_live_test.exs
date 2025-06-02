defmodule MyPodcastsWeb.NewLiveTest do
  alias MyPodcasts.Categories
  alias MyPodcasts.Files
  use MyPodcastsWeb.ConnCase

  import Phoenix.LiveViewTest

  @valid_url "valid_url"
  @invalid_url "invalid_url"

  describe "New download page" do
    setup :register_and_log_in_user

    test "valid url, file is inserted into the db", %{conn: conn, user: user} do
      {:ok, view, html} = live(conn, ~p"/")

      assert html =~ "Download new podcast from YouTube"

      assert view
             |> form("#url_form", %{url: @valid_url})
             |> render_submit() =~ "Getting information about the video"

      html = render_async(view)
      assert html =~ "some description"
      assert html =~ "<img src=\"thumbnail.jpg\""

      [
        %{
          title: "some title",
          description: "some description",
          thumbnail: "thumbnail.jpg",
          hash: "some hash",
          duration: 99
        }
      ] = Files.get_by_user_id(user.id)

      # test download link
      {:error, {:redirect, %{to: "/file/some hash"}}} =
        view
        |> element("#download-link")
        |> render_click()
    end

    test "invalid url, no new files", %{conn: conn, user: user} do
      {:ok, view, html} = live(conn, ~p"/")

      assert html =~ "Download new podcast from YouTube"

      assert view
             |> form("#url_form", %{url: @invalid_url})
             |> render_submit() =~ "Getting information about the video"

      html = render_async(view)
      assert html =~ "Failed to download audio file, please make sure the URL is correct."
      refute html =~ "some description"
      refute html =~ "<img src=\"thumbnail.jpg\""

      assert Files.get_by_user_id(user.id) == []
    end

    test "valid url, add to a category", %{conn: conn, user: user} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert view
             |> form("#url_form", %{url: @valid_url})
             |> render_submit() =~ "Getting information about the video"

      html = render_async(view)
      assert html =~ "some description"

      [file] = Files.get_by_user_id(user.id)

      # open add to category modal
      assert view
             |> element("#edit-#{file.id}")
             |> render_click() =~
               "Adding the file to a category automatically includes it in the RSS feed"

      add_new_category(view, "qwer")

      # select new category
      category = Categories.get_by_user_and_name(user.id, "qwer")

      view
      |> form("#category-form", %{category_id: category.id})
      |> render_submit()

      # FIXME: make sure all concurrent requsts are done
      Process.sleep(50)

      # file is updated in the database
      file = Files.get_file!(file.id)
      assert file.category_id == category.id
    end
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
