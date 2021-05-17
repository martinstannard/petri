defmodule Petri.Scenes.Behaviours.Pause do
  @moduledoc """
  stops updates and hence 'pauses' the scene
  """
  alias Scenic.Graph
  import Scenic.Components

  @doc "adds state and UI for pause"
  def init({inner_state, graph}, _opts \\ %{}) do
    ng =
      graph
      |> button("Start",
        id: :pause,
        theme: :primary,
        translate: {500, 730}
      )

    nis = inner_state
    |> Map.put(:paused, true)
    {nis, ng}
  end

  @doc "toggles the paused state and updates the UI"
  def call({inner_state, graph}) do
    paused = !inner_state.paused

    ng =
      graph
      |> Graph.modify(:pause, &button(&1, pause_label(paused)))

    nis = %{inner_state | paused: paused}

    {nis, ng}
  end

  def pause_label(true), do: "Start"
  def pause_label(_), do: "Stop"
end
