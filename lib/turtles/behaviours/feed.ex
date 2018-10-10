defmodule Processor.Turtles.Behaviour.Feed do
  @moduledoc """
  functionality to feed from a food source(s)
  """

  def init(state, max_health) do
    state
    |> Map.put(:max_health, max_health)
  end

  def call(%{food_distance: fd} = state) when fd < 20_000.0 do
    %{
      state
      | health: min(state.health + (20_000.0 - fd) / 8_000.0, state.max_health)
    }
  end

  def call(state), do: state
end
