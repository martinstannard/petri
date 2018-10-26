defmodule Processor.Creatures.Smeller do
  @moduledoc """
  a creature that uses smell to find food
  """
  use GenServer

  import Utils.Modular
  import Scenic.Primitives

  alias Scenic.Graph
  alias Processor.Creatures.Behaviour.{Feed, Health, Move, Smell, Wiggle}

  @max_health 1000
  @tri {{0, -15}, {8, 8}, {-8, 8}}
  @modules [Feed, Health, Smell, Move, Wiggle]

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
      tick: 0
    }

    {
      :ok,
      state
      |> init_modules(List.delete(@modules, Move))
      |> Move.init(%{angle: angle(), velocity: Enum.random(5..20) / 4.0})
    }
  end

  def handle_cast({:update, world}, state) do
    new_state =
      state
      |> call_modules(@modules, world)

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

  defp health_colour(health) do
    percentage = health / @max_health
    r = round(255.0 * (1.0 - percentage))
    g = round(255.0 * percentage)
    {r, g, 0x22}
  end

  defp angle do
    :rand.uniform() / 10.0 * Enum.random([-1.0, 1.0])
  end
end
