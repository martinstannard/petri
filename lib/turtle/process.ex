defmodule Processor.Process do
  @moduledoc """
  A simple representation of a process
  """
  use GenServer

  alias Scenic.Graph

  import Scenic.Primitives

  def start_link(count) do
    GenServer.start_link(__MODULE__, count)
  end

  def update(pid) do
    GenServer.cast(pid, :update)
  end

  def draw(pid, graph) do
    GenServer.call(pid, {:draw, graph})
  end

  def add_to_graph(pid, graph) do
    GenServer.call(pid, {:add_to_graph, graph})
  end

  def init(count) do
    state = %{
      id: "process_#{count}",
      x: 30 + rem(count, 20) * 65,
      y: 130 + div(count, 20) * 65,
      color: :green,
      tick: 0
    }

    {
      :ok,
      state
    }
  end

  def handle_cast(:update, state) do
    {:noreply, state |> tick}
  end

  def handle_call({:draw, graph}, _, state) do
    {:reply, paint(graph, state), state}
  end

  def handle_call({:add_to_graph, graph}, _, state) do
    {:reply, add(graph, state), state}
  end

  defp tick(state) do
    %{state | tick: state.tick + 1}
  end

  defp add(graph, state) do
    graph
    |> circle(30, id: state.id)
    |> text(to_string(:erlang.pid_to_list(self)), id: "#{state.id}_label")
  end

  defp paint(graph, state) do
    graph
    |> Graph.modify(
      state.id,
      &circle(&1, 30,
        translate: {state.x, state.y},
        fill: {:color, :green}
      )
    )
    |> Graph.modify(
      "#{state.id}_label",
      &text(&1, to_string(:erlang.pid_to_list(self)),
        translate: {state.x - 20, state.y},
        font_size: 12,
        fill: {:color, :yellow}
      )
    )
  end
end
