defmodule Processor.Creatures.Behaviour.Colorize do
  @moduledoc """
  changes a turtle's color
  """

  alias Processor.Creatures.Utils

  def init(state, _opts \\ %{}) do
    state
    |> Map.put(:color_trigger, Enum.random(1..10) / 100.0)
  end

  def call(state, _) do
    if :rand.uniform() < state.color_trigger do
      %{state | color: Utils.random_color()}
    else
      state
    end
  end
end
