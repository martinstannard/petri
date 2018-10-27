defmodule Petri.Scenes.Behaviours.Pause do
  @moduledoc """
  stops updates and hence 'pauses' the scene
  """
  alias Scenic.Graph
  import Scenic.Components

  @doc "adds state and UI for pause"
  def init(state, _opts \\ %{}) do
    g =
      state.graph
      |> button("Start",
        id: :pause,
        theme: :primary,
        translate: {500, 730}
      )

    state
    |> Map.put(:paused, true)
    |> Map.put(:graph, g)
  end

  @doc "toggles the paused state and updates the UI"
  def call(state) do
    paused = !state.paused

    g =
      state.graph
      |> Graph.modify(:pause, &button(&1, pause_label(paused)))

    %{state | graph: g, paused: paused}
  end

  def pause_label(true), do: "Start"
  def pause_label(_), do: "Stop"
end
