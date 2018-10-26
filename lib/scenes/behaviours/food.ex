defmodule Processor.Scenes.Behaviours.Food do
  alias Scenic.Graph
  alias Processor.Creatures.Supervisor
  import Scenic.Primitives, only: [{:circle, 3}, {:update_opts, 2}]

  @moduledoc """
  A food source for the scene. Food has a position and a quantity.
  Provides food functionality to the scene.
  """

  @food_quantity 4_000.0

  @doc "add food state variable to scene state"
  def init(state, opts \\ %{}) do
    {x, y} = coords()

    state
    |> Map.put(:food_x, x)
    |> Map.put(:food_y, y)
    |> Map.put(:food_quantity, @food_quantity)
    |> move
  end

  @doc "update the state"
  def call(state) do
    state
    |> consume
    |> move?
    |> update_graph
  end

  @doc "if the food is exhausted, reset and move to a new location"
  def move?(%{food_quantity: fa} = state) when fa < 0.0 do
    move(state)
  end

  @doc "quantity is > 0, stay put"
  def move?(state), do: state

  @doc "move the food and reset the quantity of food"
  def move(state) do
    {x, y} = coords()

    g =
      state.graph
      |> Graph.modify(:food, &update_opts(&1, translate: {x, y}, fill: colour(state)))
      |> Graph.modify(:food_glow, &update_opts(&1, translate: {x, y}))

    %{state | graph: g, food_x: x, food_y: y, food_quantity: @food_quantity}
  end

  @doc "add primitives to the graph"
  def add(graph) do
    initial_coords = coords()

    graph
    |> circle(10, id: :food, t: initial_coords, fill: {:color, :yellow})
    |> circle(141,
      id: :food_glow,
      t: initial_coords,
      fill: {:radial, {0, 0, 0, 141, {0xFF, 0xFF, 0x33, 0x40}, {0xFF, 0xFF, 0x33, 0x20}}}
    )
  end

  defp update_graph(state) do
    g =
      state.graph
      |> Graph.modify(:food, &update_opts(&1, fill: {:color, colour(state)}))

    %{state | graph: g}
  end

  defp coords do
    {Enum.random(100..700), Enum.random(100..700)}
  end

  defp consume(state) do
    %{state | food_quantity: state.food_quantity - consumed()}
  end

  defp consumed do
    Supervisor.apply(&Processor.Creatures.Smeller.state/1)
    |> Enum.map(&Map.get(&1, :eaten))
    |> Enum.sum()
  end

  defp colour(state) do
    alpha = max(0, round(state.food_quantity / @food_quantity * 255))
    {0xFF, 0xFF, 0x33, min(255, alpha)}
  end
end
