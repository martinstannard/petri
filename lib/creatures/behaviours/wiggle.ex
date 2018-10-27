defmodule Petri.Creatures.Behaviour.Wiggle do
  @moduledoc """
  wiggles the heading slightly each move
  """

  def init(state, opts \\ %{}) do
    state
  end

  def call(state, _) do
    wiggle = state.angle * :rand.uniform() / 3.0 * Enum.random([1.0, -1.0])

    %{
      state
      | heading: state.heading - wiggle
    }
  end
end
