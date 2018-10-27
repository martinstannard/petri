defmodule Processor.Creatures.Messenger do
  @moduledoc """
  A simple representation of a process
  """
  use GenServer

  alias Scenic.Graph
  alias Processor.Creatures.Supervisor
  alias Processor.Creatures.Behaviour.Count

  import Scenic.Primitives, only: [{:text, 2}, {:text, 3}, {:rrect, 3}, {:update_opts, 2}]

  @columns 7
  @off_color :green

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

  def ping_count(pid) do
    GenServer.cast(pid, :ping_count)
  end

  def state(pid) do
    GenServer.cast(pid, :state)
  end

  def init(count) do
    {
      :ok,
      %{
        id: id(),
        button_id: button_id(),
        text_id: text_id(),
        count_id: text_id(),
        x: 30 + rem(count, @columns) * 110,
        y: 80 + div(count, @columns) * 70,
        color: @off_color,
        dirty: false
      }
      |> Count.init()
    }
  end

  def handle_call({:draw, graph}, _, state) do
    {:reply, paint(graph, state), %{state | dirty: false}}
  end

  def handle_call({:add_to_graph, graph}, _, state) do
    {:reply, add(graph, state), state}
  end

  def handle_call(:ping_count, _, state) do
    {:reply, state.count, state}
  end

  def handle_call(:state, _, state) do
    {:reply, state, state}
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
    send_to_sibling(count - 1)
    Process.send_after(self(), :unping, 500)

    state
    |> Map.put(:color, :lime)
    |> Map.put(:dirty, true)
    |> Count.call()
  end

  defp paint(graph, %{dirty: false}) do
    graph
  end

  defp paint(graph, %{dirty: true} = state) do
    graph
    |> Graph.modify(button_id(), &update_opts(&1, fill: state.color))
    |> Graph.modify(text_id(), &update_opts(&1, fill: :white))
    |> Graph.modify(count_id(), &text(&1, "#{state.count}"))
  end

  defp send_to_sibling(count) when count < 1, do: nil

  defp send_to_sibling(count) do
    Supervisor.random_child()
    |> deliver(count)
  end

  defp deliver([], _), do: nil

  defp deliver(sibling, count) do
    Process.send_after(sibling, {:ping, count}, 50)
  end

  defp add(graph, state) do
    graph
    |> rrect({100, 60, 6},
      id: button_id(),
      fill: {:color, @off_color},
      stroke: {4, :grey},
      t: {state.x, state.y}
    )
    |> text(id(),
      id: text_id(),
      fill: {:color, :white},
      t: {state.x + 10, state.y + 20},
      font_size: 20
    )
    |> text("#{state.count}",
      id: count_id(),
      fill: {:color, :white},
      text_align: :center,
      t: {state.x + 50, state.y + 50},
      font_size: 40
    )
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
