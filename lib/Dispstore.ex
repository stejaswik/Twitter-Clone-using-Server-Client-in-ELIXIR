# Waiting till it reaches convergence
defmodule Dispstore do
  use GenServer

  def start_link(stack) do
    GenServer.start_link(__MODULE__, stack, name: __MODULE__)
  end

  def init(stack) do
    {:ok, stack}
  end

  def save_node(val) do
    GenServer.cast(__MODULE__, {:savenode, [val]})
  end

  def print() do
    GenServer.call(__MODULE__, :printval)
  end

  def handle_cast({:savenode, list}, stack) do
    #IO.inspect(list)
    #keep adding converged nodes to existing state
    stack = List.flatten([list] ++ [stack])
    len = length(stack)
    start = Enum.at(stack, len-2)
    endtime = System.system_time(:millisecond)
    diff = endtime - start
    stack = List.delete_at(stack, len-3)
    stack = List.insert_at(stack, len-3, diff)

    #retrieve initialized convergence_rate, start_time values from stack
    convergence_rate = List.last(stack)

    #No Failure: Donot exit until 100% convergence is achieved
    #A factor of 4 is added because the state "stack" is initialized with a 4-list
    if len >= convergence_rate+4 do
      parent_pid = Enum.at(stack, len-4)
      send(parent_pid, :work_is_done)
    end
    {:noreply, stack}
  end

  def handle_call(:printval, _from, stack) do
    {:reply, stack, stack}
  end
end
