defmodule Processor.Turtles.Behaviour.Feed do
  @moduledoc """
  functionality to feed from a food source(s)
  """

  @max_distance 20_000.0

  def init(state, max_health) do
    state
    |> Map.put(:max_health, max_health)
    |> Map.put(:eaten, 0.0)
  end

  def call(%{food_distance: fd} = state) when fd < @max_distance do
    health_bonus = (@max_distance - state.food_distance) / (@max_distance / 2.0)

    %{
      state
      | health: new_health(state, health_bonus),
        eaten: health_bonus
    }
  end

  def call(state) do
    %{state | eaten: 0}
  end

  def new_health(state, health_bonus) do
    state.max_health
    |> min(state.health + health_bonus)
  end
end
