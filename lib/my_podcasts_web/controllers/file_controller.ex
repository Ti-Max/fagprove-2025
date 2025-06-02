defmodule MyPodcastsWeb.FileController do
  alias MyPodcasts.Downloader
  alias MyPodcasts.Files
  use MyPodcastsWeb, :controller

  def index(conn, %{"file_hash" => file_hash}) do
    case Files.get_by_hash(file_hash) do
      nil ->
        conn
        |> Plug.Conn.send_resp(404, "Not Found")

      %{hash: hash} ->
        conn
        |> send_file(200, Downloader.get_file_location(hash))
    end
  end
end
