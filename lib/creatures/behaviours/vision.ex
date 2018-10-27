defmodule Petri.Creatures.Behaviour.Vision do
  @moduledoc """
  models bifocal vision
  Each eye has a width and offset from straight ahead
  If the bearing to an object falls within the arc of the eye, then
  the eye can 'see' the object
  """
  @twopi 2.0 * :math.pi()

  def init(state, _opts \\ %{}) do
    state
    |> Map.put(:eye_width, :rand.uniform() * :math.pi())
    |> Map.put(:eye_offset, :rand.uniform() * :math.pi())
  end

  def call(state, world) do
    %{state | heading: clamp(state.heading + angle(state, world))}
  end

  def angle(state, world) do
    bearing = bearing(world.food_x, world.food_y, state)
    turn(left_eye_sees(bearing, state), right_eye_sees(bearing, state), state.angle)
  end

  def turn(true, true, _angle), do: 0.0
  def turn(false, true, angle), do: angle
  def turn(true, false, angle), do: angle * -1.0
  def turn(false, false, angle), do: angle

  def left_eye_sees(bearing, state) do
    rs = (@twopi - state.eye_offset + state.eye_width / 2.0) |> clamp
    ls = (@twopi - state.eye_offset - state.eye_width / 2.0) |> clamp

    eye_sees(ls, rs, bearing)
  end

  def right_eye_sees(bearing, state) do
    rs = (state.eye_offset + state.eye_width / 2.0) |> clamp
    ls = (state.eye_offset - state.eye_width / 2.0) |> clamp

    eye_sees(ls, rs, bearing)
  end

  def eye_sees(ls, rs, bearing) when ls < rs do
    bearing < rs and bearing > ls
  end

  def eye_sees(ls, rs, bearing) do
    bearing < rs or bearing > ls
  end

  def bearing(px, py, state) do
    a = :math.atan2(state.x - px, py - state.y) + :math.pi()

    (state.heading - a) |> clamp
  end

  defp clamp(angle) when angle > @twopi, do: angle - @twopi
  defp clamp(angle) when angle < 0, do: angle + @twopi
  defp clamp(angle), do: angle
end
