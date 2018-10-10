defmodule Processor.Scene.Processes do
  use Scenic.Scene

  alias Scenic.Graph

  import Scenic.Primitives

  alias Processor.Component.{ArenaUI, Nav}

  alias Processor.Turtles.{
    Process,
    Supervisor
  }

  alias Processor.Arena.{
    Birth,
    Food,
    Reaper
  }

  @animate_ms 16

  @graph Graph.build(font: :roboto, font_size: 24)

  def init(_, opts) do
    Supervisor.clear()
    viewport = opts[:viewport]

    graph =
      @graph
      |> Nav.add_to_graph(__MODULE__)
      |> ArenaUI.add_to_graph(__MODULE__)
      |> push_graph()

    # start a very simple animation timer
    {:ok, _} = :timer.send_interval(@animate_ms, :animate)

    state = %{
      viewport: viewport,
      graph: graph,
      count: 0
    }

    {:ok, state}
  end

  def handle_info(:animate, state) do
    new_state =
      state
      |> update
      |> draw

    {:noreply, new_state}
  end

  def filter_event({:click, :btn_one}, _, state) do
    {:stop, Birth.hatch_n(state, 1, Process)}
  end

  def filter_event({:click, :btn_ten}, _, state) do
    {:stop, Birth.hatch_n(state, 10, Process)}
  end

  def filter_event({:click, id}, _, state) when is_pid(id) do
    pid = to_string(:erlang.pid_to_list(id))
    IO.inspect("filter_event #{pid}")
    DynamicSupervisor.terminate_child(TurtleSupervisor, id)
    new_state = %{state | graph: Graph.delete(state.graph, id)}
    {:stop, new_state}
  end

  def update(state) do
    Supervisor.children()
    |> Enum.each(&Process.update(&1, state))

    state
  end

  def draw(state) do
    graph =
      Supervisor.children()
      |> Enum.reduce(state.graph, &Process.draw(&1, &2))
      |> push_graph

    %{
      state
      | graph: graph
    }
  end
end
