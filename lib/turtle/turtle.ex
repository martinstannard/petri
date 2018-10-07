defmodule Processor.Turtle do
  use GenServer

  alias Scenic.Graph

  alias Processor.Turtle.Utils

  alias Processor.Turtle.Behaviour.{
    Colorize,
    Scale,
    Smell
  }

  import Scenic.Primitives

  @tri {{0, -20}, {10, 10}, {-10, 10}}
  def start_link(id) do
    GenServer.start_link(__MODULE__, id)
  end

  def update(pid, world) do
    GenServer.cast(pid, {:update, world})
  end

  def draw(pid, graph) do
    GenServer.call(pid, {:draw, graph})
  end

  def add_to_graph(pid, graph) do
    GenServer.call(pid, {:add_to_graph, graph})
  end

  def init(id) do
    state = %{
      id: id,
      heading: Enum.random(0..628) / 100.0,
      angle: Enum.random(20..250) / 1000.0,
      velocity: Enum.random(0..100) / 20.0,
      x: Enum.random(0..800),
      y: Enum.random(0..800),
      color: Utils.random_color(),
      scale: Enum.random(0..2000) / 1000.0 + 1.0,
      tick: 0
    }

    new_state =
      state
      |> Smell.init()

    #   |> Scale.init()

    {
      :ok,
      new_state
    }
  end

  def handle_cast({:update, world}, state) do
    new_state =
      state
      |> tick
      # |> right(Enum.random(0..50) / state.angle)
      # |> forward
      |> Smell.call(world)
      |> move()

    # |> reverse
    # |> Colorize.call()
    # |> Scale.call()

    {:noreply, new_state}
  end

  def handle_call({:draw, graph}, _, state) do
    {:reply, paint(graph, state), state}
  end

  def handle_call({:add_to_graph, graph}, _, state) do
    {:reply, add(graph, state), state}
  end

  defp paint(graph, state) do
    graph
    |> Graph.modify(
      state.id,
      &update_opts(&1,
        translate: {state.x, state.y},
        rotate: state.heading,
        # scale: state.scale,
        fill: {:color, state.color}
      )
    )
  end

  defp add(graph, state) do
    graph
    |> triangle(@tri, id: state.id)
  end

  def tick(state) do
    %{state | tick: state.tick + 1}
  end

  def move(state) do
    state
    |> forward
    |> turn
  end

  def turn(%{food_delta: fd} = state) when fd < 0 do
    state
  end

  def turn(state) do
    right(state, state.angle)
  end

  def right(state, angle) do
    %{state | heading: state.heading - angle}
  end

  def forward(state) do
    %{
      state
      | x: new_x(state.x, state.heading, state.velocity),
        y: new_y(state.y, state.heading, state.velocity)
    }
  end

  defp new_x(x, heading, distance) do
    new_x = x + :math.sin(heading) * distance
    bound(new_x)
  end

  defp new_y(y, heading, distance) do
    new_y = y - :math.cos(heading) * distance
    bound(new_y)
  end

  defp bound(coord) when coord > 800.0, do: coord - 800.0
  defp bound(coord) when coord < 0.0, do: coord + 800.0
  defp bound(coord), do: coord
end
