defmodule Processor.Scenes.Behaviours.Reaper do
  alias Scenic.Graph

  alias Processor.Turtles.Supervisor

  @moduledoc """
  remove dead creatures
  """

  @doc "init func - noop"
  def init(state, opts \\ %{}), do: state

  @doc "called every tick to reap dead creatures"
  def call(state) do
    %{state | graph: terminator(state)}
  end

  @doc "reduces over children to remove dead creatures"
  defp terminator(state) do
    Supervisor.children()
    |> Enum.reduce(state.graph, fn pid, g ->
      pid
      |> terminate(g, state.creature, state.creature.health(pid))
    end)
  end

  @doc "creature is dead - remove it. Terminates the process and deletes
  the creature from the graph"
  defp terminate(pid, graph, creature, health) when health < 1 do
    id = creature.id(pid)

    Supervisor.terminate(pid)

    # TODO - we need to remove all primitives associated with the creature
    graph
    |> Graph.delete(id)
  end

  @doc "creature is alive - do nothing"
  defp terminate(_, graph, _, _), do: graph
end
