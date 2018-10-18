defmodule Processor.Turtles.Seer do
  @moduledoc """
  Implements a turtle with vision
  """
  use GenServer

  import Utils.Modular
  import Scenic.Primitives

  alias Scenic.Graph
  alias Processor.Turtles.Utils
  alias Processor.Turtles.Behaviour.{Feed, Health, Move, Vision}

  @tri {{0, -15}, {8, 8}, {-8, 8}}
  @modules [Health, Feed, Vision, Move]

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
    {
      :ok,
      %{id: id}
      |> init_modules(@modules)
    }
  end

  def handle_cast({:update, world}, state) do
    {:noreply, state |> call_modules(@modules, world)}
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
        fill: {:color, state.color}
      )
    )
  end

  defp add(graph, state) do
    graph
    |> triangle(@tri, id: state.id)
    |> text("test", id: "#{state.id}_text", fill: {:color, :blue})
  end
end
