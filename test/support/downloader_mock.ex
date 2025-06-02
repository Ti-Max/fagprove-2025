defmodule MyPodcasts.DownloaderMock do
  @moduledoc """
  Mock behaiviour of the Downloader module
  """

  def run("valid_url", _live_view_pid),
    do:
      {:completed,
       %{
         "description" => "some description",
         "title" => "some title",
         "hash" => "some hash",
         "thumbnail" => "thumbnail.jpg",
         "duration" => 99
       }}

  def run("invalid_url", _live_view_pid), do: :failed
end
