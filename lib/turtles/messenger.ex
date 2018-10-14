defmodule Processor.Turtles.Messenger do
  @moduledoc """
  A simple representation of a process
  """
  use GenServer

  alias Scenic.Graph
  alias Processor.Turtles.Supervisor

  import Scenic.Primitives
  import Scenic.Components

  @columns 7
  @off_color :dim_grey
  @on_color :red

  def start_link(count) do
    GenServer.start_link(__MODULE__, count)
  end

  def draw(pid, graph) do
    GenServer.call(pid, {:draw, graph})
  end

  def add_to_graph(pid, graph) do
    GenServer.call(pid, {:add_to_graph, graph})
  end

  def ping(pid, count) do
    GenServer.cast(pid, {:ping, count})
  end

  def init(count) do
    {
      :ok,
      %{
        id: to_string(:erlang.pid_to_list(self)),
        text_id: to_string(:erlang.pid_to_list(self)) <> "_text",
        x: 30 + rem(count, @columns) * 110,
        y: 80 + div(count, @columns) * 50,
        color: @off_color,
        tick: 0
      }
    }
  end

  def handle_call({:draw, graph}, _, state) do
    {:reply, paint(graph, state), state}
  end

  def handle_call({:add_to_graph, graph}, _, state) do
    {:reply, add(graph, state), state}
  end

  def handle_cast({:ping, count}, state) do
    {:noreply, do_ping(count, state)}
  end

  def handle_info(:unping, state) do
    {:noreply, %{state | color: @off_color}}
  end

  def handle_info({:ping, count}, state) do
    {:noreply, do_ping(count, state)}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  defp do_ping(count, state) do
    send_to_sibling(count)
    Process.send_after(self(), :unping, 500)
    %{state | color: ping_color(count)}
  end

  defp tick(state) do
    %{state | tick: state.tick + 1}
  end

  defp add(graph, state) do
    graph
    |> rrect({100, 40, 6},
      id: state.id,
      fill: {:color, @off_color},
      stroke: {3, :grey},
      t: {state.x, state.y}
    )
    |> text(state.id,
      id: "#{state.id}_text",
      fill: {:color, :white},
      t: {state.x + 15, state.y + 25},
      font_size: 20
    )
  end

  defp paint(graph, state) do
    graph
    |> Graph.modify(state.id, &update_opts(&1, fill: state.color))
    |> Graph.modify(state.text_id, &update_opts(&1, fill: :white))
  end

  defp send_to_sibling(0), do: nil

  defp send_to_sibling(count) do
    Supervisor.random_child()
    |> deliver(count)
  end

  def deliver([], _), do: nil

  def deliver(sibling, count) do
    Process.send_after(sibling, {:ping, count - 1}, 50)
  end

  def ping_color(count) do
    green = round(155.0 + 5.0 * count)
    {0x88, green, 0x33}
  end
end
