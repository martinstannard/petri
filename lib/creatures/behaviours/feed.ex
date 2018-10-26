defmodule Processor.Creatures.Behaviour.Feed do
  @moduledoc """
  functionality to feed from a food source(s)
  calculates distance to food, and adds health if close enough
  """

  @max_distance 20_000.0

  @doc "add food variables to creature state"
  def init(state, _opts \\ %{}) do
    state
    |> Map.put(:food_distance, @max_distance)
    |> Map.put(:food_delta, 0.0)
    |> Map.put(:eaten, 0.0)
  end

  def call(state, world) do
    distance = distance_to_food(state, world)

    %{
      state
      | health: new_health(state, distance |> bonus),
        food_distance: distance,
        food_delta: distance - state.food_distance,
        eaten: distance |> bonus
    }
  end

  defp bonus(distance) when distance < @max_distance do
    (@max_distance - distance) / (@max_distance / 2.0)
  end

  defp bonus(_), do: 0

  defp new_health(state, health_bonus) do
    state.max_health
    |> min(state.health + health_bonus)
  end

  defp distance_to_food(state, %{food_x: food_x, food_y: food_y}) do
    a = (food_x - state.x) * (food_x - state.x)
    b = (food_y - state.y) * (food_y - state.y)
    a + b
  end
end
