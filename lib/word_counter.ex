defmodule Simple.WordCounter do
  @moduledoc """
  Documentation for WordCounter.
  """

  require Logger

  @doc """
  EScript main function which accepts CLI input arguments and run
  """
  def main(argv) do
    argv
    |> parse_args
    |> run
  end

  defp parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [ help: :boolean ],
                                      aliases: [ h:    :help ])
    case parse do
      { [ help: true ], _, _ }
        -> :help
      {_, [ dir_path, word ], _}
        -> { dir_path, word }
      _ -> :help
    end
  end


  @doc """
  Start word counting with multi-processes and measure the time span

  ## Examples

      iex> Simple.WordCounter.run("/path/to/directory", "one word")

  """
  def run({dir_full_path, word}) do

    Enum.each 1..10, fn num_processes ->
      {time, result} = :timer.tc(Simple.Scheduler, :run,
        [
          num_processes,
          Excercise.WordCounter,
          :count_p,
          [word],
          fn () -> 
            {:ok, files} = File.ls(dir_full_path)
            Enum.map(files, fn file -> Path.join(dir_full_path, file) end)
          end
        ]
      )
      if num_processes === 1 do
        IO.puts inspect result
        IO.puts "\n # time (ms)"
      end 
      :io.format "~2B ~.2f~n", [num_processes, time/1_000.0]
    end
  end
end
