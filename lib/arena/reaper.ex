defmodule Processor.Arena.Reaper do
  alias Scenic.Graph

  alias Processor.Turtles.{
    Supervisor,
    Turtle
  }

  @moduledoc """
  remove dead creatures
  """

  def init(state), do: state

  def call(state) do
    %{state | graph: terminator(state)}
  end

  defp terminator(state) do
    Supervisor.children()
    |> Enum.reduce(state.graph, fn pid, g ->
      pid
      |> terminate(g, state.creature, state.creature.health(pid))
    end)
  end

  defp terminate(pid, graph, creature, health) when health < 1 do
    id = creature.id(pid)

    Supervisor.terminate(pid)

    graph
    |> Graph.delete(id)
  end

  defp terminate(_, graph, _, _), do: graph
end
