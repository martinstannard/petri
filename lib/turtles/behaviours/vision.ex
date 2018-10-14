defmodule Processor.Turtles.Behaviour.Vision do
  @moduledoc """
  models vision
  """

  def init(state) do
    state
    |> Map.put(:eye_width, 1.0)
    |> Map.put(:eye_offset, 60.0)
    |> Map.put(:bearing, 60.0)
  end

  def call(state, world) do
    bearing = bearing(world.food_x, world.food_y, state)

    %{state | heading: bearing + state.angle, bearing: bearing}
  end

  defp bearing(px, py, state) do
    y = state.x - px
    x = py - state.y

    :math.atan2(y, x) + :math.pi()
  end
end
