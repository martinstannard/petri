defmodule Processor.Scene.Walking do
  use Scenic.Scene

  alias Scenic.Graph

  import Scenic.Primitives

  alias Processor.Component.Nav

  alias Processor.Turtles.{
    Supervisor,
    Walker
  }

  alias Processor.Arena.{
    Birth
  }

  @animate_ms 16

  @graph Graph.build(font: :roboto, font_size: 24)
  def init(_, opts) do
    Supervisor.clear()
    viewport = opts[:viewport]

    graph =
      @graph
      |> Nav.add_to_graph(__MODULE__)
      |> push_graph()

    # start a very simple animation timer
    {:ok, _} = :timer.send_interval(@animate_ms, :animate)

    state = %{
      creature: Walker,
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
    {:stop, Birth.hatch_n(state, 1)}
  end

  def filter_event({:click, :btn_ten}, _, state) do
    {:stop, Birth.hatch_n(state, 10)}
  end

  def filter_event({:value_changed, :run, run_state}, _, state) do
    {:stop, %{state | run_state: run_state}}
  end

  def update(state) do
    Supervisor.children()
    |> Enum.each(&Walker.update(&1, state))

    state
    |> Reaper.call()
    |> Birth.call()
  end

  def draw(state) do
    graph =
      Supervisor.children()
      |> Enum.reduce(state.graph, &Walker.draw(&1, &2))
      |> push_graph

    %{
      state
      | graph: graph
    }
  end
end
