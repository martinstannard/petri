defmodule Processor.Scene.Panopticon do
  use Scenic.Scene

  alias Scenic.Graph

  import Scenic.Primitives

  alias Processor.Component.{ArenaUI, Nav}
  alias Processor.Turtles.{Supervisor, Seer}
  alias Processor.Arena.{Birth, Food, Reaper}

  @animate_ms 16

  @graph Graph.build(font: :roboto, font_size: 24)
         |> text("0",
           id: :population,
           translate: {20, 750},
           font_size: 64
         )

  def init(_, opts) do
    Supervisor.clear()
    viewport = opts[:viewport]

    graph =
      @graph
      |> Nav.add_to_graph(__MODULE__)
      |> ArenaUI.add_to_graph(__MODULE__)
      |> Food.add()
      |> push_graph()

    # start a very simple animation timer
    {:ok, _} = :timer.send_interval(@animate_ms, :animate)

    state =
      %{
        creature: Seer,
        viewport: viewport,
        graph: graph,
        count: 0,
        food_x: 0,
        food_y: 0
      }
      |> Food.init()
      |> Food.move()

    {:ok, state}
  end

  def handle_info(:animate, state) do
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
    {:stop, Food.move(state)}
  end

  def update(state) do
    turtles()
    |> Enum.each(&Seer.update(&1, state))

    state
    |> Reaper.call()
    |> Birth.call()
    |> Food.call()
    |> population
  end

  def draw(state) do
    graph =
      turtles()
      |> Enum.reduce(state.graph, &Seer.draw(&1, &2))
      |> push_graph

    %{
      state
      | graph: graph
    }
  end

  def turtles do
    Supervisor.children()
  end

  def turtle_count do
    Supervisor.count()
  end

  def population(state) do
    g =
      state.graph
      |> Graph.modify(:population, &text(&1, "#{turtle_count()}"))

    %{state | graph: g}
  end
end
