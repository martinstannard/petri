defmodule Processor.Arena.Reaper do
  alias Scenic.Graph
  alias Processor.Turtles.Turtle

  @moduledoc """
  remove dead turtles
  """
  def call(state, pids) do
    graph =
      pids
      |> Enum.reduce(state.graph, fn pid, g ->
        pid
        |> terminate(state, state.creature.health(pid))
      end)

    %{
      state
      | graph: graph
    }
  end

  defp terminate(turtle, graph, health) when health < 1 do
    id = Turtle.id(turtle)
    DynamicSupervisor.terminate_child(TurtleSupervisor, turtle)

    graph
    |> Graph.delete(id)
  end

  defp terminate(_, graph, _), do: graph
end
