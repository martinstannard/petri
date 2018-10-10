defmodule Processor.Turtles.Turtle do
  use GenServer

  alias Scenic.Graph

  alias Processor.Turtles.Utils

  alias Processor.Turtles.Behaviour.{
    Colorize,
    Feed,
    Scale,
    Smell
  }

  import Scenic.Primitives

  @max_health 1000
  @tri {{0, -15}, {8, 8}, {-8, 8}}

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

  def health(pid) do
    GenServer.call(pid, :health)
  end

  def id(pid) do
    GenServer.call(pid, :id)
  end

  def init(id) do
    state = %{
      id: id,
      heading: Enum.random(0..628) / 100.0,
      angle: Enum.random(20..100) / 1000.0 * Enum.random([-1.0, 1.0]),
      velocity: Enum.random(5..100) / 20.0,
      x: Enum.random(0..800),
      y: Enum.random(0..800),
      color: Utils.random_color(),
      scale: Enum.random(0..2000) / 1000.0 + 1.0,
      health: @max_health,
      tick: 0
    }

    new_state =
      state
      |> Smell.init()
      |> Feed.init(@max_health)

    {
      :ok,
      new_state
    }
  end

  def handle_cast({:update, world}, state) do
    new_state =
      state
      |> tick
      |> Smell.call(world)
      |> Feed.call()
      |> move()

    {:noreply, new_state}
  end

  def handle_call({:draw, graph}, _, state) do
    {:reply, paint(graph, state), state}
  end

  def handle_call({:add_to_graph, graph}, _, state) do
    {:reply, add(graph, state), state}
  end

  def handle_call(:health, _, state) do
    {:reply, state.health, state}
  end

  def handle_call(:id, _, state) do
    {:reply, state.id, state}
  end

  defp paint(graph, state) do
    graph
    |> Graph.modify(
      state.id,
      &update_opts(&1,
        translate: {state.x, state.y},
        rotate: state.heading,
        # scale: state.scale,
        fill: {:color, health_colour(state.health)}
      )
    )
  end

  defp add(graph, state) do
    graph
    |> triangle(@tri, id: state.id)
  end

  def tick(state) do
    %{state | tick: state.tick + 1, health: state.health - 1}
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

  defp health_colour(health) do
    percentage = health / @max_health
    r = round(255.0 * (1.0 - percentage))
    g = round(255.0 * percentage)
    {r, g, 0x22}
  end
end
