defmodule Processor.Scene.Arena do
  use Scenic.Scene

  alias Scenic.Graph

  import Utils.Modular
  import Scenic.Primitives

  alias Processor.Component.{ArenaUI, Nav}
  alias Processor.Turtles.{Generic, Supervisor, Smeller}
  alias Processor.Arena.{Birth, Food, Reaper}

  @animate_ms 16
  @modules [Food, Reaper, Birth]

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

    state = %{
      creature: Smeller,
      viewport: viewport,
      graph: graph,
      count: 0
    }

    {:ok, state |> init_modules(@modules, %{birth_rate: 0.01})}
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
    Supervisor.children()
    |> Enum.each(&state.creature.update(&1, state))

    state
    |> call_modules(@modules)
    |> population
  end

  def draw(state) do
    graph =
      Supervisor.children()
      |> Enum.reduce(state.graph, &state.creature.draw(&1, &2))
      |> push_graph

    %{
      state
      | graph: graph
    }
  end

  def population(state) do
    g =
      state.graph
      |> Graph.modify(:population, &text(&1, "#{Supervisor.count()}"))

    %{state | graph: g}
  end
end
