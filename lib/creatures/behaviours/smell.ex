defmodule Processor.Creatures.Behaviour.Smell do
  @moduledoc """
  allow a turtle to smell food
  """

  def init(state, opts \\ %{}) do
    state
  end

  def call(state, _world) do
    state
    |> turn
  end

  def turn(%{food_delta: fd} = state) when fd < 0 do
    state
  end

  def turn(state) do
    state
    |> Map.put(:heading, state.heading - state.angle)
    |> clamp_heading
  end

  def clamp_heading(%{heading: heading} = state) when heading > 6.283185307179586 do
    %{state | heading: state.heading - 2.0 * :math.pi()}
  end

  def clamp_heading(%{heading: heading} = state) when heading < 0 do
    %{state | heading: state.heading + 2.0 * :math.pi()}
  end

  def clamp_heading(state), do: state
end
