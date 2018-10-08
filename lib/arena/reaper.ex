defmodule Processor.Arena.Reaper do
  alias Scenic.Graph
  alias Processor.Turtle

  @moduledoc """
  remove dead turtles
  """
  def call(state, turtles) do
    graph =
      turtles
      |> Enum.reduce(state.graph, fn t, g ->
        t
        |> terminate(g, Turtle.health(t))
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
