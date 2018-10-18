defmodule Processor.Scene.Processes do
  use Scenic.Scene

  import Scenic.Primitives

  alias Scenic.Graph

  alias Processor.Component.{ProcessorUI, Nav}

  alias Processor.Turtles.{Messenger, Supervisor}

  alias Processor.Arena.Birth

  @animate_ms 16
  @graph Graph.build(font: :roboto, font_size: 14)

  def init(_, opts) do
    Supervisor.clear()
    viewport = opts[:viewport]

    graph =
      @graph
      |> Nav.add_to_graph(__MODULE__)
      |> ProcessorUI.add_to_graph(__MODULE__)

    {:ok, _} = :timer.send_interval(@animate_ms, :tick)

    state = %{
      creature: Messenger,
      viewport: viewport,
      graph: graph,
      count: 0,
      last_frame_time: Time.utc_now()
    }

    {:ok, add_processes(70, state)}
  end

  def handle_info(:tick, state) do
    {:message_queue_len, len} = :erlang.process_info(self(), :message_queue_len)
    elapsed = Time.diff(Time.utc_now(), state.last_frame_time, :millisecond)

    if len > 10 do
      {:noreply, state}
    else
      {:noreply, draw(%{state | last_frame_time: Time.utc_now()})}
    end
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  def filter_event({:click, :btn_ten}, _, state) do
    {:stop, add_processes(10, state)}
  end

  def filter_event({:click, :ping}, _, state) do
    send_ping(0)
    {:stop, state}
  end

  def filter_event({:click, :multiping}, _, state) do
    send_ping(20)
    {:stop, state}
  end

  def filter_event({:click, id}, _, state) when is_pid(id) do
    pid = to_string(:erlang.pid_to_list(id))
    Supervisor.terminate(pid)
    new_state = %{state | graph: Graph.delete(state.graph, id)}

    {:stop, draw(new_state)}
  end

  def add_processes(count, state) do
    state
    |> Birth.hatch_n(count)
  end

  def draw(state) do
    # state
    graph =
      Supervisor.children()
      |> Enum.reduce(state.graph, &Messenger.draw(&1, &2))
      |> push_graph

    %{state | graph: graph}
  end

  def send_ping(count) do
    Supervisor.random_child()
    |> pinger(count)
  end

  def pinger(nil, _), do: nil

  def pinger(child, count) do
    child |> Messenger.ping(count)
  end
end
