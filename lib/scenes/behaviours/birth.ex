defmodule Petri.Scenes.Behaviours.Birth do
  @moduledoc """
  give birth to new turtles
  """

  @doc "adds birth_rate to creature state"
  def init(state, opts \\ %{}) do
    state
    |> Map.put(:birth_rate, opts[:birth_rate] || 0.01)
  end

  @doc "creates a new creature if a birth occurs"
  def call(state) do
    if :rand.uniform() < state.birth_rate do
      state
      |> hatch
    else
      state
    end
  end

  @doc "adds n new creatures to state"
  def hatch_n(state, count) do
    1..count
    |> Enum.reduce(state, fn _i, s ->
      hatch(s)
    end)
  end

  @doc "adds a new creature to state"
  def hatch(state) do
    {:ok, process} =
      DynamicSupervisor.start_child(CreatureSupervisor, {state.creature, state.count})

    %{
      state
      | graph: state.creature.add_to_graph(process, state.graph),
        count: state.count + 1
    }
  end
end
