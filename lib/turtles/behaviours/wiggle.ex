defmodule Processor.Turtles.Behaviour.Wiggle do
  @moduledoc """
  wiggles the heading slightly each move
  """

  def init(state) do
    state
  end

  def call(state, _) do
    wiggle = state.angle * :rand.uniform() / 3.0

    %{
      state
      | heading: state.heading - wiggle
    }
  end
end
