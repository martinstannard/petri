defmodule Processor.Arena.Food do
  alias Scenic.Graph
  alias Processor.Turtles.Supervisor
  import Scenic.Primitives, only: [{:circle, 3}, {:update_opts, 2}]

  @moduledoc """
  food/light behaviour
  """

  @food_amount 5_000.0

  def init(state) do
    {x, y} = coords()

    state
    |> Map.put(:food_x, x)
    |> Map.put(:food_y, y)
    |> Map.put(:food_amount, @food_amount)
  end

  def call(state) do
    state
    |> consume
    |> move?
    |> draw
  end

  def move?(%{food_amount: fa} = state) when fa < 0.0 do
    move(state)
  end

  def move?(state), do: state

  def move(state) do
    {x, y} = coords()

    g =
      state.graph
      |> Graph.modify(:food, &update_opts(&1, translate: {x, y}, fill: colour(state)))
      |> Graph.modify(:food_glow, &update_opts(&1, translate: {x, y}))

    %{state | graph: g, food_x: x, food_y: y, food_amount: @food_amount}
  end

  def add(graph) do
    graph
    |> circle(10, id: :food, t: coords, fill: {:color, :yellow})
    |> circle(141,
      id: :food_glow,
      t: coords,
      fill: {:radial, {0, 0, 0, 141, {0xFF, 0xFF, 0x33, 0x20}, {0xFF, 0xFF, 0x33, 0x08}}}
    )
  end

  def draw(state) do
    # IO.inspect(state, label: :food)

    g =
      state.graph
      |> Graph.modify(:food, &update_opts(&1, fill: colour(state)))

    %{state | graph: g}
  end

  defp coords do
    {Enum.random(100..700), Enum.random(100..700)}
  end

  defp consume(state) do
    %{state | food_amount: state.food_amount - consumed()}
  end

  defp consumed do
    Supervisor.apply(&Processor.Turtles.Turtle.state/1)
    |> Enum.map(&Map.get(&1, :eaten))
    |> Enum.sum()
  end

  defp colour(state) do
    alpha = max(0, round(state.food_amount / @food_amount * 255))
    {0xFF, 0xFF, 0x33, alpha}
  end
end
