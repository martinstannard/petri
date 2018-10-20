defmodule Processor.Turtles.Behaviour.Base do
  alias Processor.Turtles.Utils

  @moduledoc """
  base functionality
  """

  def init(state) do
    state
    |> Map.merge(%{
      tick: 0,
      x: Enum.random(0..800),
      y: Enum.random(0..800),
      heading: Enum.random(0..628) / 100.0,
      velocity: Enum.random(5..100) / 20.0,
      angle: Enum.random(20..100) / 1000.0 * Enum.random([-1.0, 1.0]),
      color: Utils.random_color()
    })
  end

  def call(state, _) do
    state
    |> tick
    |> forward
    |> turn
  end

  def tick(state) do
    %{state | tick: state.tick + 1}
  end

  def turn(state) do
    right(state, state.angle)
  end

  def forward(state) do
    %{
      state
      | x: new_x(state.x, state.heading, state.velocity),
        y: new_y(state.y, state.heading, state.velocity)
    }
  end

  def right(state, _angle) do
    %{state | heading: state.heading - 0.01}
  end

  defp new_x(x, heading, distance) do
    new_x = x + :math.sin(heading) * distance
    bound(new_x)
  end

  defp new_y(y, heading, distance) do
    new_y = y - :math.cos(heading) * distance
    bound(new_y)
  end

  defp bound(coord) when coord > 800.0, do: coord - 800.0
  defp bound(coord) when coord < 0.0, do: coord + 800.0
  defp bound(coord), do: coord
end
