defmodule Processor.Turtles.Behaviour.Smell do
  @moduledoc """
  allow a turtle to smell food
  """

  def init(state) do
    state
    |> Map.put(:food_distance, 1_000_000.0)
    |> Map.put(:food_delta, 0.0)
  end

  def call(state, world) do
    new_distance = distance_to_food(state, world)
    delta = new_distance - state.food_distance

    %{
      state
      | food_distance: new_distance,
        food_delta: delta
    }
  end

  defp distance_to_food(state, %{food_x: food_x, food_y: food_y}) do
    a = (food_x - state.x) * (food_x - state.x)
    b = (food_y - state.y) * (food_y - state.y)
    a + b
  end
end
