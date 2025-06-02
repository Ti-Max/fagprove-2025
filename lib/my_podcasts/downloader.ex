defmodule MyPodcasts.Downloader do
  @moduledoc """
  Fetches information about a YouTube video & downloads it
  """

  @yt_dlp "yt-dlp"
  @format "mp3"

  @doc """
  Use yt-dlp to fetch info about a YouTube video and download it
  """
  def run(url, live_view_pid) do
    hash = Ecto.UUID.generate()
    file_dest = get_file_location(hash)

    with file_info <- fetch_file_info(url),
         port <- start_download(url, file_dest),
         :download_completed <- listen(port, live_view_pid) do
      file_info = file_info |> Map.put("hash", hash)
      {:completed, file_info}
    else
      _ -> :failed
    end
  end

  defp fetch_file_info(url) do
    cmd =
      System.cmd(@yt_dlp, [
        url,
        "--cookies",
        "./cookies.txt",
        "--simulate",
        "--print",
        "%(.{title,description,duration,thumbnail})j"
      ])

    with {output, 0} <- cmd,
         {:ok, file_info} <- Jason.decode(output) do
      IO.puts("Fetched file info:")
      dbg(file_info)
      file_info
    else
      error ->
        IO.puts("Failed to fetch video info")
        dbg(error)
        :error
    end
  end

  defp start_download(url, file_dest) do
    Port.open({:spawn_executable, System.find_executable(@yt_dlp)}, [
      :binary,
      {:args,
       [
         "--cookies",
         "./cookies.txt",
         url,
         "-o",
         file_dest,
         "-x",
         "--audio-format",
         @format,
         "--progress-template",
         "%(progress)j",
         "--force-overwrites"
       ]},
      :exit_status
    ])
  end

  # read std output
  defp listen(port, live_view_pid) do
    receive do
      {^port, {:data, data}} ->
        maybe_send_info(data, live_view_pid)
        listen(port, live_view_pid)

      {^port, {:exit_status, 0}} ->
        IO.puts("Download is completed")
        :download_completed

      {^port, {:exit_status, status}} ->
        IO.puts("\nProcess exited with status #{status}")
        {:error, status}
    end
  end

  # sends download progress to LiveView
  defp maybe_send_info(data, live_view_pid) do
    case Jason.decode(data) do
      {:ok, %{"_percent" => percent}} ->
        send(live_view_pid, {:download_progress, percent})

      {:error, _error} ->
        nil
    end
  end

  # FIXME: don't use local storage
  def get_file_location(hash), do: "files/#{hash}.#{@format}"
  def get_accessible_url(hash), do: "/file/#{hash}"
end
