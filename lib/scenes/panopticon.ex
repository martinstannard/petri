defmodule Processor.Scene.Panopticon do
  use Scenic.Scene

  alias Scenic.Graph

  import Utils.Modular
  import Scenic.Primitives

  alias Processor.Component.{SmellyUI, Nav}
  alias Processor.Creatures.{Supervisor, Seer}
  alias Processor.Scenes.Behaviours.{Birth, Food, Reaper}

  @animate_ms 16
  @modules [Birth, Reaper, Food]

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
      |> SmellyUI.add_to_graph(__MODULE__)
      |> Food.add()
      |> push_graph()

    {:ok, _} = :timer.send_interval(@animate_ms, :animate)

    state =
      %{
        creature: Seer,
        viewport: viewport,
        graph: graph,
        count: 0
      }
      |> init_modules(@modules)

    {:ok, state}
  end

  def handle_info(:animate, state) do
    new_state =
      state
      |> update
      |> draw

    {:noreply, new_state}
  end

  @doc "handle event from Add 1 button"
  def filter_event({:click, :btn_one}, _, state) do
    {:stop, Birth.hatch_n(state, 1)}
  end

  @doc "handle event from Add 10 button"
  def filter_event({:click, :btn_ten}, _, state) do
    {:stop, Birth.hatch_n(state, 10)}
  end

  @doc "handle event from Move button"
  def filter_event({:click, :move_food}, _, state) do
    {:stop, Food.move(state)}
  end

  def update(state) do
    turtles()
    |> Enum.each(&Seer.update(&1, state))

    state
    |> call_modules(@modules)
    |> move_food()
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

  def move_food(state) do
    if :rand.uniform() < 0.004 do
      Food.move(state)
    else
      state
    end
  end
end
