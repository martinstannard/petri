defmodule Processor.Arena.Birth do
  @moduledoc """
  give birth to new turtles
  """

  def call(state, creature) do
    if :rand.uniform() < 0.01 do
      state
      |> hatch(creature)
    else
      state
    end
  end

  def hatch_n(state, count, creature) do
    1..count
    |> Enum.reduce(state, fn _i, s ->
      hatch(s, creature)
    end)
  end

  def hatch(state, creature) do
    {:ok, process} = DynamicSupervisor.start_child(TurtleSupervisor, {creature, state.count})

    new_state = %{
      state
      | graph: creature.add_to_graph(process, state.graph),
        count: state.count + 1
    }
  end
end
