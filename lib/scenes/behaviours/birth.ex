defmodule Petri.Scenes.Behaviours.Birth do
  @moduledoc """
  give birth to new creatures
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
  def hatch({inner_state, graph}) do
    {:ok, process} =
      DynamicSupervisor.start_child(CreatureSupervisor, {inner_state.creature, inner_state.count})

    nis = %{inner_state | count: inner_state.count + 1}
    ng = nis.creature.add_to_graph(process, graph)
    {nis, ng}
  end
end
