defmodule Helpers do
  @doc """
  Wraps socker into {:ok, socket} tumple
  """
  def ok(socket), do: {:ok, socket}

  @doc """
  Wraps socker into {:no_reply, socket} tumple
  """
  def no_reply(socket), do: {:noreply, socket}

  @doc """
  convert seconds to hours:minnutes:seconds format
  if duration is less then a minute, use 0:seconds format
  """
  def seconds_to_human(seconds),
    do: seconds |> Time.from_seconds_after_midnight() |> Time.to_iso8601() |> truncate_duration()

  defp truncate_duration("0" <> s) when byte_size(s) > 3, do: truncate_duration(s)
  defp truncate_duration(":" <> s), do: truncate_duration(s)
  defp truncate_duration(s), do: s
end
