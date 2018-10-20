defmodule Processor.Turtles.Messenger do
  @moduledoc """
  A simple representation of a process
  """
  use GenServer

  alias Scenic.Graph
  alias Processor.Turtles.Supervisor

  import Scenic.Primitives

  @columns 7
  @off_color :dim_grey

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
        x: 30 + rem(count, @columns) * 110,
        y: 80 + div(count, @columns) * 50,
        color: @off_color,
        dirty: false
      }
    }
  end

  def handle_call({:draw, graph}, _, state) do
    {:reply, paint(graph, state), %{state | dirty: false}}
  end

  def handle_call({:add_to_graph, graph}, _, state) do
    {:reply, add(graph, state), state}
  end

  def handle_cast({:ping, count}, state) do
    {:noreply, do_ping(count, state)}
  end

  def handle_info({:ping, count}, state) do
    {:noreply, do_ping(count, state)}
  end

  def handle_info(:unping, state) do
    {:noreply, %{state | color: @off_color, dirty: true}}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  defp do_ping(count, state) do
    send_to_sibling(count)
    Process.send_after(self(), :unping, 500)
    %{state | color: ping_color(count), dirty: true}
  end

  defp add(graph, state) do
    graph
    |> rrect({100, 40, 6},
      id: button_id(),
      fill: {:color, @off_color},
      stroke: {4, :grey},
      t: {state.x, state.y}
    )
    |> text(id(),
      id: text_id(),
      fill: {:color, :white},
      t: {state.x + 10, state.y + 25},
      font_size: 20
    )
  end

  defp paint(graph, %{dirty: false}) do
    graph
  end

  defp paint(graph, %{dirty: true} = state) do
    graph
    |> Graph.modify(button_id(), &update_opts(&1, fill: state.color))
    |> Graph.modify(text_id(), &update_opts(&1, fill: :white))
    |> Graph.modify(count_id(), &text(&1, "#{state.ping_count}"))
  end

  defp send_to_sibling(0), do: nil

  defp send_to_sibling(count) do
    Supervisor.random_child()
    |> deliver(count)
  end

  defp deliver([], _), do: nil

  defp deliver(sibling, count) do
    Process.send_after(sibling, {:ping, count}, 50)
  end

  defp button_id do
    id() <> "_button"
  end

  defp text_id do
    id() <> "_text"
  end

  defp count_id do
    id() <> "_count"
  end

  defp id do
    self()
    |> :erlang.pid_to_list()
    |> to_string
  end
end
