defmodule MyPodcastsWeb.FileLive.Index do
  alias MyPodcasts.Categories
  use MyPodcastsWeb, :live_view

  alias MyPodcasts.Files
  alias MyPodcasts.Downloader

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "All Files")
    |> assign(:edit_category_modal_opened?, false)
    |> ok()
  end

  @impl true
  def handle_params(params, _url, %{assigns: %{current_user: user}} = socket) do
    category = Categories.get_by_user_and_name(user.id, Map.get(params, "category", ""))

    socket
    |> assign_files(category)
    |> no_reply()
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    with file <- Files.get_file(id, socket.assigns.current_user.id),
         {:ok, _} <- Files.delete_file(file),
         :ok <- File.rm(Downloader.get_file_location(file.hash)) do
      socket |> stream_delete(:files, file) |> no_reply()
    else
      _ ->
        socket
        |> put_flash(:error, "Could not delete this file, please try again.")
        |> no_reply()
    end
  end

  def handle_event("change_category", %{"category" => ""}, socket),
    do:
      socket
      |> push_patch(to: "/files")
      |> no_reply()

  def handle_event("change_category", %{"category" => category}, socket) do
    if Enum.any?(socket.assigns.categories, &(&1.name == category)) do
      socket
      |> push_patch(to: "/files?category=#{category}")
      |> no_reply()
    else
      socket |> no_reply()
    end
  end

  def handle_event("open_edit_modal", %{"id" => id}, %{assigns: %{current_user: user}} = socket) do
    file = Files.get_file(id, user.id)

    socket
    |> assign(:file, file)
    |> assign(:edit_category_modal_opened?, true)
    |> no_reply()
  end

  def handle_event("close_edit_modal", _, socket) do
    socket
    |> assign(:edit_category_modal_opened?, false)
    |> no_reply()
  end

  @impl true
  def handle_info(:update_and_close_modal, %{assigns: %{category: category}} = socket) do
    socket
    |> assign_files(category)
    |> assign(:edit_category_modal_opened?, false)
    |> no_reply()
  end

  def handle_info(:update_files, %{assigns: %{category: category}} = socket) do
    socket
    |> assign_files(category)
    |> no_reply()
  end

  defp assign_files(%{assigns: %{current_user: user}} = socket, nil = _category) do
    files = Files.get_by_user_id(user.id)
    categories = Categories.get_by_user_id(user.id)

    socket
    |> stream(:files, files, reset: true)
    |> assign(:category, nil)
    |> assign(:categories, categories)
    |> assign(:no_results?, files == [])
  end

  defp assign_files(%{assigns: %{current_user: user}} = socket, category) do
    categories = Categories.get_by_user_id(user.id)
    category = Enum.find(categories, &(&1.name == category.name))

    if category == nil do
      assign_files(socket, nil)
    else
      files = Files.get_by_user_and_category(user.id, category.id)

      socket
      |> stream(:files, files, reset: true)
      |> assign(:category, category)
      |> assign(:categories, categories)
      |> assign(:no_results?, files == [])
    end
  end

  defp format_categories(categories) do
    [All: ""] ++ Enum.map(categories, & &1.name)
  end
end
