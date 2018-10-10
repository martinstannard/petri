defmodule Processor.Turtles.Behaviour.Scale do
  @moduledoc """
  scales a turtle based on tick and some state
  """

  def init(state) do
    state
    |> Map.put(:scale, 1.0)
    |> Map.put(:scale_speed, Enum.random(4..50))
  end

  def call(state) do
    %{
      state
      | scale: :math.sin(state.tick / state.scale_speed) + 1.5
    }
  end
end
