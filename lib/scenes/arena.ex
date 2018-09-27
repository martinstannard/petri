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
           # |> text("This is Scenic", translate: {15, 20})

           # Nav and Notes are added last so that they draw on top
           # |> Nav.add_to_graph(__MODULE__)
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
      timer: timer
    }

    {:ok, state}
  end

  def handle_info(:animate, state) do
    state.turtles
    |> Enum.each(fn t ->
      Turtle.turn(t, Enum.random(-100..100) / 300.0)
      Turtle.fd(t, 2.0)
    end)

    draw(state)

    {:noreply, state}
  end

  def handle_input({:key, {"N", :press, _} = key}, _context, state) do
    {:noreply, hatch(state)}
  end

  def handle_input({:key, {"P", :press, _} = key}, _context, state) do
    new_state =
      0..10
      |> Enum.reduce(state, fn _i, s ->
        hatch(s)
      end)

    {:noreply, new_state}
  end

  def handle_input(_input, _context, state), do: {:noreply, state}

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
    |> push_graph
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

  def add_turtle(state) do
    state.graph
    |> triangle(@tri,
      id: "turtle_#{state.count}",
      fill: {:color, :green}
    )
  end
end
