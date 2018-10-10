defmodule Processor.Turtles.Process do
  @moduledoc """
  A simple representation of a process
  """
  use GenServer

  alias Scenic.Graph

  import Scenic.Primitives
  import Scenic.Components

  @columns 7

  def start_link(count) do
    GenServer.start_link(__MODULE__, count)
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

  def init(count) do
    {
      :ok,
      %{
        id: to_string(:erlang.pid_to_list(self)),
        x: 30 + rem(count, @columns) * 110,
        y: 80 + div(count, @columns) * 50,
        tick: 0
      }
    }
    |> IO.inspect()
  end

  def handle_cast({:update, _}, state) do
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
    id = to_string(:erlang.pid_to_list(self))

    graph
    # |> circle(30, id: state.id)
    # |> text(to_string(:erlang.pid_to_list(self)), id: "#{state.id}_label")
    |> button(id, id: self())
  end

  defp paint(graph, state) do
    id = to_string(:erlang.pid_to_list(self))

    graph
    |> Graph.modify(
      self(),
      &button(&1, id,
        id: self(),
        translate: {state.x, state.y}
        # fill: {:color, :green}
      )
    )

    # |> Graph.modify(
    #   "#{state.id}_label",
    #   &text(&1, to_string(:erlang.pid_to_list(self)),
    #     translate: {state.x - 20, state.y},
    #     font_size: 12,
    #     fill: {:color, :yellow}
    #   )
    # )
  end
end
