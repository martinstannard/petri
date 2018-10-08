defmodule Processor.Arena.Food do
  alias Scenic.Graph
  import Scenic.Primitives, only: [{:circle, 3}, {:update_opts, 2}]

  @moduledoc """
  food/light behaviour
  """
  def call(state) do
    if :rand.uniform() < 0.001 do
      move_food(state)
    else
      state
    end
  end

  def add_food(graph) do
    graph
    |> circle(10, id: :food, t: coords, fill: {:color, :yellow})
  end

  def move_food(state) do
    {x, y} = coords()

    g =
      state.graph
      |> Graph.modify(:food, &update_opts(&1, translate: {x, y}))

    %{state | graph: g, food_x: x, food_y: y}
  end

  defp coords do
    {Enum.random(100..700), Enum.random(100..700)}
  end
end
