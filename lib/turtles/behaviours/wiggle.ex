defmodule Processor.Turtles.Behaviour.Wiggle do
  @moduledoc """
  wiggles the heading slightly each move
  """

  def init(state) do
    state
  end

  def call(state) do
    wiggle = state.angle * :rand.uniform() / 3.0

    %{
      state
      | heading: state.heading - wiggle
    }
  end
end
