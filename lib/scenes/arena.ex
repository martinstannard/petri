defmodule Processor.Scene.Arena do
  use Scenic.Scene

  alias Scenic.Graph

  import Scenic.Primitives

  alias Processor.Component.Nav
  alias Processor.Component.ArenaUI
  alias Processor.Turtle
  alias Processor.Process

  alias Processor.Arena.{
    Birth,
    Food,
    Reaper
  }

  @animate_ms 16

  @graph Graph.build(font: :roboto, font_size: 24)
         |> text("0",
           id: :population,
           translate: {20, 700},
           font_size: 64
         )

  def init(_, opts) do
    viewport = opts[:viewport]

    graph =
      @graph
      |> Nav.add_to_graph(__MODULE__)
      |> ArenaUI.add_to_graph(__MODULE__)
      |> Food.add_food()
      |> push_graph()

    # start a very simple animation timer
    {:ok, _} = :timer.send_interval(@animate_ms, :animate)

    state = %{
      viewport: viewport,
      graph: graph,
      count: 0,
      food_x: 0,
      food_y: 0
    }

    {:ok, state}
  end

  def handle_info(:animate, state) do
    # {ms, new_state} = :timer.tc(&update/1, [state])
    # IO.inspect(ms, label: "UPDATE:")
    # {ms, newer_state} = :timer.tc(&draw/1, [new_state])
    # IO.inspect(ms, label: "DRAW:")
    new_state =
      state
      |> update
      |> draw

    {:noreply, new_state}
  end

  def filter_event({:click, :btn_one}, _, state) do
    {:stop, Birth.hatch_n(state, 1)}
  end

  def filter_event({:click, :btn_ten}, _, state) do
    {:stop, Birth.hatch_n(state, 10)}
  end

  def filter_event({:click, :move_food}, _, state) do
    {:stop, Food.move_food(state)}
  end

  def update(state) do
    turtles
    |> Enum.each(&Turtle.update(&1, state))

    state
    |> Reaper.call(turtles)
    |> Birth.call()
    |> Food.call()
    |> population
  end

  def draw(state) do
    graph =
      turtles
      |> Enum.reduce(state.graph, &Turtle.draw(&1, &2))
      |> push_graph

    %{
      state
      | graph: graph
    }
  end

  def turtles do
    TurtleSupervisor
    |> DynamicSupervisor.which_children()
    |> Enum.map(fn t ->
      {_, pid, _, _} = t
      pid
    end)
  end

  def turtle_count do
    TurtleSupervisor
    |> DynamicSupervisor.which_children()
    |> length
  end

  def population(state) do
    g =
      state.graph
      |> Graph.modify(:population, &text(&1, "#{turtle_count}"))

    %{state | graph: g}
  end
end
