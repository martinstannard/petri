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

  @graph Graph.build(font: :roboto, font_size: 24)
         |> group(fn g ->
           g
           |> text("This is Scenic", translate: {15, 20})

           # Nav and Notes are added last so that they draw on top
           # |> Nav.add_to_graph(__MODULE__)
           # |> Notes.add_to_graph(@notes)
         end)

  def init(data, opts) do
    IO.inspect(data, label: "data")
    IO.inspect(opts, label: "opts")
    viewport = opts[:viewport]

    graph =
      @graph
      |> push_graph()

    # start a very simple animation timer
    # {:ok, timer} = :timer.send_interval(@animate_ms, :animate)

    state = %{
      viewport: viewport,
      graph: graph,
      turtles: [],
      count: 0
      # timer: timer
    }

    {:ok, state}
  end

  def handle_input({:key, {"N", :press, _} = key}, _context, state) do
    {:ok, turtle} = Processor.Turtle.start("turtle_#{state.count}")

    new_state = %{
      state
      | graph: add_turtle(state),
        turtles: [turtle] ++ state.turtles,
        count: state.count + 1
    }

    update(new_state)

    {:noreply, new_state}
  end

  def handle_input(_input, _context, state), do: {:noreply, state}

  def update(state) do
    graph = state.graph

    state.turtles
    |> Enum.reduce(graph, fn t, g ->
      turtle = Turtle.state(t)
      IO.inspect(turtle)

      g
      |> Graph.modify(turtle.id, &text(&1, "turtle", translate: {turtle.x, turtle.y}))
    end)
    |> push_graph
  end

  def add_turtle(state) do
    graph =
      state.graph
      |> circle(20,
        id: "circle_#{state.count}",
        translate: {200, 30 + state.count * 30}
      )
      |> text("#{state.count}",
        id: "turtle_#{state.count}",
        translate: {200, 30 + state.count * 30}
      )

    # |> push_graph

    graph
  end
end
