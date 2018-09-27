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
           |> text("Population: ", id: :population, translate: {20, 750})
           |> button("+1", id: :btn_one, theme: :primary, translate: {600, 750})
           |> button("+10", id: :btn_ten, theme: :primary, translate: {700, 750})
           |> text("Velocity: ", id: :velocity_text, translate: {200, 750})
           |> slider({{0.0, 10.0}, 2.0}, id: :velocity, t: {250, 750})

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

    {:ok, state}
  end

  def handle_info(:animate, state) do
    state.turtles
    |> Enum.each(fn t ->
      Turtle.turn(t, Enum.random(-100..100) / 600.0)
      Turtle.fd(t, state.velocity)
    end)

    draw(state)

    {:noreply, state}
  end

  def draw(state) do
    graph = state.graph

    state.turtles
    |> Enum.reduce(state.graph, fn t, g ->
      turtle = Turtle.state(t)

      g
      |> Graph.modify(
        turtle.id,
        &triangle(&1, @tri,
          translate: {turtle.x, turtle.y},
          rotate: turtle.heading,
          fill: {:color, turtle.color}
        )
      )
    end)
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
    {:ok, turtle} = Processor.Turtle.start("turtle_#{state.count}")

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

  def filter_event({:value_changed, :velocity, velocity}, _, state) do
    new_state = %{state | velocity: velocity}
    {:stop, new_state}
  end
end
