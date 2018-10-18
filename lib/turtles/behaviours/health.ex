defmodule Processor.Turtles.Behaviour.Health do
  @moduledoc """
  adds health to a creature
  """

  @max_health 1000

  def init(state) do
    state
    |> Map.put(:age, 0)
    |> Map.put(:health, @max_health)
    |> Map.put(:max_health, @max_health)
    |> Map.put(:color, :green)
  end

  def call(state, _) do
    %{state | health: state.health - 1, age: state.age + 1, color: health_colour(state.health)}
  end

  defp health_colour(health) do
    percentage = health / 1000.0
    r = round(255.0 * (1.0 - percentage))
    g = round(255.0 * percentage)
    {r, g, 0x22}
  end
end
