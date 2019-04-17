defmodule Simple.Scheduler do

  @moduledoc """
  A simple scheduler for run and gather results from worker processes
  """

  require Logger

  def run(num_processes, module, func, func_args \\ [], queue_func) do
    current = self()
    queue = queue_func.()
    func_args = [current | func_args]
    Logger.debug inspect(func_args)
    (1..num_processes)
      |> Enum.map(fn(_) -> spawn(module, func, func_args) end)
      |> schedule_processes(queue, []) # (queue, results_list)
  end

  defp schedule_processes(processes, queue, results) do
    receive do
      {:ready, pid} when queue != [] ->
        [ next | tail ] = queue
        send pid, {:work, next, self()}
        schedule_processes(processes, tail, results)
      {:ready, pid} ->
        send pid, {:shutdown}
        if length(processes) > 1 do
          schedule_processes(List.delete(processes, pid), queue, results)
        else
          results
        end
      {:result, queue_item, result, _pid} ->
        schedule_processes(processes, queue, [ {queue_item, result} | results ])
    end
  end

end