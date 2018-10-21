defmodule Processor.Turtles.Behaviour.Move do
  @moduledoc """
  implements movement and turning
  """

  def init(state) do
    state
    |> Map.put(:x, Enum.random(0..800))
    |> Map.put(:y, Enum.random(0..800))
    |> Map.put(:heading, 0.0)
    |> Map.put(:velocity, Enum.random(5..20) / 4.0)
    |> Map.put(:angle, :rand.uniform() / 4.0 * Enum.random([-1.0, 1.0]))

    # |> Map.put(:angle, (:rand.uniform() + 0.47) * Enum.random([-1.0, 1.0]))
  end

  def call(state, _) do
    state
    |> forward
    |> clamp_heading
  end

  def forward(state) do
    %{
      state
      | x: new_x(state.x, state.heading, state.velocity),
        y: new_y(state.y, state.heading, state.velocity)
    }
  end

  def turn(state) do
    state
    |> Map.put(:heading, state.heading - state.angle)
    |> clamp_heading
  end

  defp clamp_heading(%{heading: heading} = state) when heading > 6.283185307179586 do
    %{state | heading: state.heading - 2.0 * :math.pi()}
  end

  defp clamp_heading(%{heading: heading} = state) when heading < 0 do
    %{state | heading: state.heading + 2.0 * :math.pi()}
  end

  defp clamp_heading(state), do: state

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
