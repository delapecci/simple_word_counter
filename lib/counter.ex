defmodule Excercise.WordCounter do

  @moduledoc """
  Actual work to count word
  """

  require Logger

  def count_p(scheduler, word) do
    Logger.debug "Scheduler " <> inspect(scheduler)
    send scheduler, {:ready, self()}
    receive do
      {:work, file, client} ->
        num = count(file, word)
        Logger.debug "Result #{file} : #{inspect(num)}"
        send client, {:result, file, num, self()}
        count_p(scheduler, word)
      {:shutdown} ->
        exit(:normal)
    end
  end

  defp count(file_path, word) do
    File.stream!(file_path)
      |> Enum.reduce(0, fn (l, c) ->
        c + count_in_line(l, word)
      end)
  end

  defp count_in_line(l, w) do
    {:ok, regex} = Regex.compile(w)
    length(Regex.scan(regex, l))
  end
end