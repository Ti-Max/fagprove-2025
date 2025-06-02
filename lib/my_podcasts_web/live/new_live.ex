defmodule MyPodcastsWeb.New do
  alias MyPodcasts.Categories
  alias MyPodcasts.Files
  alias MyPodcasts.Downloader

  use MyPodcastsWeb, :live_view

  @downloader Application.compile_env(:my_podcasts, :downloader)

  @impl true
  def render(assigns) do
    ~H"""
    <.header class="text-center">
      New download
      <:subtitle>Download new podcast from YouTube</:subtitle>
    </.header>

    <div class="space-y-2">
      <.form
        :let={f}
        for={%{}}
        id="url_form"
        phx-submit={if @status in [nil, :success, :failed], do: "start_download", else: ""}
        class="w-full"
      >
        <.label for="url_input">URL of a YouTube video</.label>
        <div class="flex gap-2 w-full">
          <div class="grow">
            <.input id="url_input" field={f[:url]} type="text" required class="mt-0" />
          </div>
          <.button style_type={:secondary} disabled={@status not in [nil, :success]} class="!p-2">
            <.icon name="hero-magnifying-glass" class="w-6 h-6" />
          </.button>
        </div>
      </.form>

      <div>
        <%= case @status do %>
          <% :initializing -> %>
            Getting information about the video
            <.icon name="hero-arrow-path" class="ml-1 h-6 w-6 animate-spin" />
          <% :downloading -> %>
            Downloading
            <div class="h-4 w-18 border border-gray-300">
              <div class="h-full bg-blue-300" style={"width: #{@progress}%"} />
            </div>
          <% :processing -> %>
            Processing audio file <.icon name="hero-arrow-path" class="ml-1 h-6 w-6 animate-spin" />
          <% :success -> %>
            <div class="flex gap-8 mt-4 h-full">
              <div class="relative shrink-0 basis-[28rem]">
                <img src={@file.thumbnail} class="rounded-lg" />
                <div class="absolute font-semibold bottom-1 right-1 rounded bg-black/70 text-white py-1 px-2 text-md">
                  {seconds_to_human(@file.duration)}
                </div>
              </div>
              <div class="flex flex-col space-between">
                <div class="space-y-2 h-full">
                  <h2 class="text-xl font-semibold line-clamp-[2] text-ellipsis">
                    {@file.title}
                  </h2>
                  <%= if @file.description do %>
                    <p
                      class="line-clamp-[7] text-sm text-zinc-600 font-medium"
                      style="word-break: break-word;"
                      title={@file.description}
                    >
                      {@file.description}
                    </p>
                  <% else %>
                    <span class="italic text-zinc-500">No description</span>
                  <% end %>
                </div>
                <div class="space-x-2">
                  <a
                    id="download-link"
                    href={Downloader.get_accessible_url(@file.hash)}
                    class="text-sm font-semibold leading-6"
                    download
                  >
                    <.button>
                      <.icon name="hero-arrow-down-tray" class="mr-1 h-6 w-6" />.mp3
                    </.button>
                  </a>
                  <.button id={"edit-#{@file.id}"} phx-click="open_edit_modal" style_type={:secondary}>
                    Add to a category
                  </.button>
                </div>
              </div>
            </div>
          <% :failed -> %>
            <p class="text-red-600">
              Failed to download audio file, please make sure the URL is correct.
            </p>
          <% nil -> %>
        <% end %>
      </div>

      <.modal
        :if={@edit_category_modal_opened?}
        id="edit-category-modal"
        show
        on_cancel={JS.push("close_edit_modal")}
      >
        <.live_component
          module={MyPodcastsWeb.EditCategory}
          id="edit_file"
          file={@file}
          categories={@categories}
          user={@current_user}
        />
      </.modal>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, %{assigns: %{current_user: user}} = socket) do
    socket
    |> assign(:current_user, user)
    |> assign(:progress, nil)
    |> assign(:status, nil)
    |> assign(:file, nil)
    |> assign(:edit_category_modal_opened?, false)
    |> ok()
  end

  # def handle_event("start_download", p, socket) do
  #   dbg(p)
  #   socket |> no_reply()
  # end

  @impl true
  def handle_event("start_download", %{"url" => url}, socket) do
    live_view_pid = self()

    socket
    |> assign(:status, :initializing)
    |> start_async(:download_task, fn ->
      @downloader.run(url, live_view_pid)
    end)
    |> no_reply()
  end

  def handle_event("open_edit_modal", _, %{assigns: %{current_user: user}} = socket) do
    socket
    |> assign(:edit_category_modal_opened?, true)
    |> assign(:categories, Categories.get_by_user_id(user.id))
    |> no_reply()
  end

  def handle_event("close_edit_modal", _, socket) do
    socket
    |> assign(:edit_category_modal_opened?, false)
    |> no_reply()
  end

  @impl true
  def handle_async(:download_task, {:ok, {:completed, file_info}}, socket) do
    {:ok, file} = save_file(socket.assigns.current_user.id, file_info)

    socket
    |> assign(:status, :success)
    |> assign(:file, file)
    |> no_reply()
  end

  def handle_async(:download_task, {:ok, :failed}, socket) do
    socket
    |> assign(:status, :failed)
    |> no_reply()
  end

  @impl true
  def handle_info({:download_progress, progress}, socket) do
    socket
    |> assign(:status, if(progress < 100, do: :downloading, else: :processing))
    |> assign(:progress, progress)
    |> no_reply()
  end

  def handle_info(:update_and_close_modal, %{assigns: %{current_user: user, file: file}} = socket) do
    file = Files.get_file(file.id, user.id)

    socket
    |> assign(:file, file)
    |> assign(:edit_category_modal_opened?, false)
    |> assign(:categories, Categories.get_by_user_id(user.id))
    |> no_reply()
  end

  def handle_info(:update_files, %{assigns: %{current_user: user, file: file}} = socket) do
    file = Files.get_file(file.id, user.id)

    socket
    |> assign(:file, file)
    |> assign(:categories, Categories.get_by_user_id(user.id))
    |> no_reply()
  end

  defp save_file(user_id, file_info) do
    file_info
    |> Map.put("user_id", user_id)
    |> Files.create_file()
  end
end
