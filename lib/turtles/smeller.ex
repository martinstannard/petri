defmodule Processor.Turtles.Smeller do
  @moduledoc """
  a creature that uses smell to find food
  """
  use GenServer

  import Utils.Modular
  import Scenic.Primitives

  alias Scenic.Graph
  alias Processor.Turtles.Utils
  alias Processor.Turtles.Behaviour.{Feed, Health, Move, Smell, Wiggle}

  @max_health 1000
  @tri {{0, -15}, {8, 8}, {-8, 8}}
  @modules [Feed, Health, Smell, Move]

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

  def state(pid) do
    GenServer.call(pid, :state)
  end

  def init(id) do
    state = %{
      id: id,
      heading: Enum.random(0..628) / 100.0,
      angle: Enum.random(20..100) / 1000.00 * Enum.random([-1.0, 1.0]),
      velocity: Enum.random(5..100) / 20.0,
      x: Enum.random(0..800),
      y: Enum.random(0..800),
      tick: 0
    }

    {
      :ok,
      state |> init_modules(@modules)
    }
  end

  def handle_cast({:update, world}, state) do
    new_state =
      state
      # |> tick
      |> call_modules(@modules, world)

    # |> forward
    # |> turn

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

  def handle_call(:state, _, state) do
    {:reply, state, state}
  end

  defp paint(graph, state) do
    graph
    |> Graph.modify(
      state.id,
      &update_opts(&1,
        translate: {state.x, state.y},
        rotate: state.heading,
        fill: {:color, health_colour(state.health)}
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

  # def turn(state) do
  #   %{state | heading: state.heading + 2.0 * :math.pi()}
  #   state
  #   |> Map.put(:heading, state.heading - state.angle)
  # end

  def turn(%{food_delta: fd} = state) when fd < 0 do
    state
  end

  def turn(state) do
    state
    |> Map.put(:heading, state.heading - state.angle)
    |> clamp_heading
  end

  def clamp_heading(%{heading: heading} = state) when heading > 6.283185307179586 do
    %{state | heading: state.heading - 2.0 * :math.pi()}
  end

  def clamp_heading(%{heading: heading} = state) when heading < 0 do
    %{state | heading: state.heading + 2.0 * :math.pi()}
  end

  def clamp_heading(state), do: state

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
