defmodule Processor.Scene.Arena do
  use Scenic.Scene

  alias Scenic.Graph
  alias Scenic.ViewPort

  import Scenic.Primitives
  import Scenic.Components

  alias Processor.Component.Nav
  alias Processor.Component.Notes
  alias Processor.Turtle

  @notes """
  \"Arena\" turtles
  """

  @animate_ms 16
  @tri {{0, -20}, {10, 10}, {-10, 10}}

  @graph Graph.build(font: :roboto, font_size: 24)
         |> group(fn g ->
           g
           |> text("Turtles: ", id: :population, translate: {20, 750})
           |> button("+1", id: :btn_one, theme: :primary, translate: {600, 750})
           |> button("+10", id: :btn_ten, theme: :primary, translate: {700, 750})

           # Nav and Notes are added last so that they draw on top
           |> Nav.add_to_graph(__MODULE__)

           # |> Notes.add_to_graph(@notes)
         end)

  def init(data, opts) do
    viewport = opts[:viewport]

    graph =
      @graph
      |> push_graph()

    # start a very simple animation timer
    {:ok, timer} = :timer.send_interval(@animate_ms, :animate)

    state = %{
      viewport: viewport,
      graph: graph,
      turtles: [],
      count: 0,
      velocity: 2.0,
      timer: timer
    }

    new_state = hatch_n(state, 1)

    {:ok, new_state}
  end

  def handle_info(:animate, state) do
    update(state)
    draw(state)

    {:noreply, state}
  end

  def update(state) do
    turtles
    |> Enum.each(&Turtle.update(&1))
  end

  def draw(state) do
    turtles
    |> Enum.reduce(state.graph, &Turtle.draw(&1, &2))
    |> Graph.modify(:population, &text(&1, "Population: #{state.count}"))
    |> push_graph
  end

  def hatch_n(state, count) do
    1..count
    |> Enum.reduce(state, fn _i, s ->
      hatch(s)
    end)
  end

  def hatch(state) do
    {:ok, turtle} =
      DynamicSupervisor.start_child(TurtleSupervisor, {Turtle, "turtle_#{state.count}"})

    new_state = %{
      state
      | graph: add_turtle(state),
        turtles: [turtle] ++ state.turtles,
        count: state.count + 1
    }
  end

  def add_turtle(%{graph: graph, count: count}) do
    graph
    |> triangle(@tri,
      id: "turtle_#{count}",
      fill: {:color, :green}
    )
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
