defmodule MyPodcastsWeb.EditCategory do
  alias MyPodcasts.Files.Category
  alias MyPodcasts.Categories
  use MyPodcastsWeb, :live_component

  alias MyPodcasts.Files

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-end">
      <.header>
        Add to a category
        <:subtitle>Adding the file to a category automatically includes it in the RSS feed</:subtitle>
      </.header>

      <.form
        :let={_f}
        for={%{}}
        id="category-form"
        phx-target={@myself}
        phx-submit="save"
        class="mt-4 space-y-4 w-full"
      >
        <div class="space-y-2">
          <div class="space-x-4">
            <input
              type="radio"
              id="category-all"
              name="category_id"
              value="none"
              checked={@file.category_id == nil}
            />
            <label for="category-all">None</label>
          </div>
          <div :for={category <- @categories} class="flex justify-between items-center">
            <div class="space-x-4">
              <input
                type="radio"
                id={"category-#{category.id}-radio"}
                name="category_id"
                value={category.id}
                checked={@file.category_id == category.id}
              />
              <label for={"category-#{category.id}-radio"}>{category.name}</label>
            </div>
            <button
              type="button"
              phx-target={@myself}
              phx-click="delete_category"
              phx-value-id={category.id}
              title="delete category"
              data-confirm={"Are you sure you want to delete '#{category.name}' category?"}
              class="hover:pointer"
            >
              <.icon name="hero-x-mark" class="h-4 w-4" />
            </button>
          </div>
        </div>
      </.form>
      <%= case  @new_category_state do %>
        <% :hidden -> %>
          <.button
            id="add-new-category"
            phx-target={@myself}
            phx-click="add_new_category"
            type="button"
            class="mt-4 w-full"
            style_type={:secondary}
          >
            <.icon name="hero-plus" />
          </.button>
        <% :edit -> %>
          <.form
            :let={f}
            for={@new_category_changeset}
            id="new-category-form"
            phx-target={@myself}
            phx-submit="save_new_category"
            class="mt-4 space-y-4 w-full"
          >
            <div class="flex w-full gap-2">
              <div class="w-full">
                <.input
                  id={Ecto.UUID.generate()}
                  field={f[:name]}
                  type="text"
                  class="w-full"
                  autofocus
                />
              </div>
              <.button style_type={:secondary} class="!p-2 h-fit">
                <.icon name="hero-check" />
              </.button>
              <.button
                phx-target={@myself}
                type="button"
                style_type={:secondary}
                phx-click="cancel_new_category"
                class="!p-2 h-fit"
              >
                <.icon name="hero-x-mark" />
              </.button>
            </div>
          </.form>
      <% end %>
      <.button type="submit" form="category-form" class="ml-auto mt-4">Save</.button>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket
    |> assign(assigns)
    |> assign(:new_category_state, :hidden)
    |> assign(:new_category_changeset, Category.changeset(%{}))
    |> ok()
  end

  @impl true
  def handle_event("save", %{"category_id" => "none"}, %{assigns: %{file: file}} = socket) do
    {:ok, _file} = Files.update_category(file, nil)
    notify_parent(:update_and_close_modal)

    socket
    |> no_reply()
  end

  def handle_event(
        "save",
        %{"category_id" => category_id},
        %{assigns: %{file: file, categories: categories}} = socket
      ) do
    with {id, _} <- Integer.parse(category_id),
         %{id: id} <- Enum.find(categories, &(&1.id == id)),
         {:ok, _file} <- Files.update_category(file, id) do
      notify_parent(:update_and_close_modal)

      socket
      |> no_reply()
    else
      e ->
        dbg(e)
        socket |> no_reply()
    end
  end

  def handle_event(
        "delete_category",
        %{"id" => id},
        %{assigns: %{categories: categories}} = socket
      ) do
    with {id, _} <- Integer.parse(id),
         category <- categories |> Enum.find(&(&1.id == id)),
         Categories.delete_category(category) do
      notify_parent(:update_files)

      socket
      |> no_reply()
    else
      e ->
        dbg(e)
        socket |> no_reply()
    end
  end

  def handle_event("add_new_category", _, socket) do
    socket
    |> assign(:new_category_state, :edit)
    |> no_reply()
  end

  def handle_event(
        "save_new_category",
        %{"category" => %{"name" => name}},
        %{assigns: %{user: user}} = socket
      ) do
    case Categories.create_category(%{
           name: name,
           user_id: user.id,
           rss_feed: Ecto.UUID.generate()
         }) do
      {:ok, _} ->
        notify_parent(:update_files)

        socket
        |> assign(:new_category_state, :hidden)
        |> no_reply()

      {:error, changeset} ->
        dbg(changeset)

        socket
        |> assign(:new_category_changeset, changeset)
        |> no_reply()
    end
  end

  def handle_event("cancel_new_category", _, socket) do
    socket
    |> assign(:new_category_state, :hidden)
    |> no_reply()
  end

  defp notify_parent(msg), do: send(self(), msg)
end
