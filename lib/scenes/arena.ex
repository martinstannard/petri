defmodule Processor.Scene.Arena do
  use Scenic.Scene

  alias Scenic.Graph

  import Scenic.Primitives

  alias Processor.Component.Nav
  alias Processor.Component.ArenaUI
  alias Processor.Turtle

  @animate_ms 16
  @tri {{0, -20}, {10, 10}, {-10, 10}}

  @graph Graph.build(font: :roboto, font_size: 24)

  def init(data, opts) do
    viewport = opts[:viewport]

    graph =
      @graph
      |> push_graph()

    # start a very simple animation timer
    {:ok, _} = :timer.send_interval(@animate_ms, :animate)

    state = %{
      viewport: viewport,
      graph: graph,
      count: 0
    }

    new_state = hatch_n(state, 1)

    {:ok, new_state}
  end

  def handle_info(:animate, state) do
    state
    |> update
    |> draw

    {:noreply, state}
  end

  def update(state) do
    turtles
    |> Enum.each(&Turtle.update(&1))

    state
  end

  def draw(state) do
    turtles
    |> Enum.reduce(state.graph, &Turtle.draw(&1, &2))
    |> Nav.add_to_graph(__MODULE__)
    |> ArenaUI.add_to_graph(__MODULE__)
    |> Graph.modify(:population, &text(&1, "Population: #{state.count}"))
    |> push_graph
  end

  def hatch(state) do
    DynamicSupervisor.start_child(TurtleSupervisor, {Turtle, "turtle_#{state.count}"})

    new_state = %{
      state
      | graph: add_turtle(state),
        count: state.count + 1
    }
  end

  def hatch_n(state, count) do
    1..count
    |> Enum.reduce(state, fn _i, s ->
      hatch(s)
    end)
  end

  def add_turtle(%{graph: graph, count: count}) do
    graph
    |> triangle(@tri, id: "turtle_#{count}")
  end

  def filter_event({:click, :btn_one}, _, state) do
    {:stop, hatch_n(state, 1)}
  end

  def filter_event({:click, :btn_ten}, _, state) do
    {:stop, hatch_n(state, 10)}
  end

  def turtles do
    TurtleSupervisor
    |> DynamicSupervisor.which_children()
    |> Enum.map(fn t ->
      {_, pid, _, _} = t
      pid
    end)
  end
end
