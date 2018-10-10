defmodule Processor.Turtles.Generic do
  use GenServer

  alias Scenic.Graph

  alias Processor.Turtles.Utils

  alias Processor.Turtles.Behaviour.{
    Base,
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

  # def id(pid) do
  #   GenServer.call(pid, :id)
  # end

  def init(id) do
    state = %{
      id: id,
      modules: [Base]
    }

    new_state =
      state
      |> Base.init()

    {
      :ok,
      new_state
    }
  end

  def handle_cast({:update, world}, state) do
    new_state =
      state
      |> Base.call()

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
        fill: {:color, state.color}
      )
    )
  end

  defp add(graph, state) do
    graph
    |> triangle(@tri, id: state.id)
  end
end
