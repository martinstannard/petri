defmodule Processor.Arena.Birth do
  @moduledoc """
  give birth to new turtles
  """

  def call(state) do
    if :rand.uniform() < 0.01 do
      state
      |> hatch
    else
      state
    end
  end

  def hatch_n(state, count) do
    1..count
    |> Enum.reduce(state, fn _i, s ->
      hatch(s)
    end)
  end

  def hatch(state) do
    {:ok, process} =
      DynamicSupervisor.start_child(TurtleSupervisor, {state.creature, state.count})

    %{
      state
      | graph: state.creature.add_to_graph(process, state.graph),
        count: state.count + 1
    }
  end
end
