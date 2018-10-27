defmodule Petri.Creatures.Behaviour.Count do
  @moduledoc """
  adds a count member to a creature's state
  """

  def init(state, _opts \\ %{}) do
    state
    |> Map.put(:count, 0)
  end

  def call(state) do
    state
    |> Map.put(:count, state.count + 1)
  end
end
