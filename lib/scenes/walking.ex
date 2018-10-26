defmodule Processor.Scene.Walking do

  @moduledoc """
  A scene for displaying Walkers
  """

  use Scenic.Scene

  import Utils.Modular
  import Scenic.Primitives
  import Scenic.Components

  alias Scenic.Graph
  alias Scenic.ViewPort
  alias Processor.Component.{Nav, WalkingUI}
  alias Processor.Creatures.{Supervisor, Walker}
  alias Processor.Scenes.Behaviours.{Birth, Reaper}

  @animate_ms 30
  @update_ms 30
  @modules [Birth, Reaper]

  @graph Graph.build(font: :roboto, font_size: 24)
         |> text("Count 0",
           id: :population,
           translate: {600, 120},
           font_size: 64
         )
         |> text("0 ms",
           id: :frames,
           translate: {700, 120},
           font_size: 32
         )
         |> button("Start",
           id: :run,
           theme: :primary,
           translate: {500, 730}
         )

  def init(_, opts) do
    Supervisor.clear()

    # {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} =
    #   opts[:viewport]
    #   |> ViewPort.info()

    graph =
      @graph
      |> Nav.add_to_graph(__MODULE__)
      |> WalkingUI.add_to_graph(__MODULE__)

    # start a very simple animation timer
    {:ok, _} = :timer.send_interval(@animate_ms, :animate)
    {:ok, _} = :timer.send_interval(@update_ms, :update)

    state =
      %{
        creature: Walker,
        viewport: opts[:viewport],
        graph: graph,
        count: 0,
        run_state: false,
        last_frame_time: Time.utc_now()
      }
      |> init_modules(@modules)

    {:ok, state}
  end

  def handle_info(:animate, state) do
    new_state =
      state
      |> modify_ui
      |> draw

    {:noreply, new_state}
  end

  def handle_info(:update, %{run_state: false} = state), do: {:noreply, state}

  def handle_info(:update, state) do
    new_state =
      state
      |> update

    {:noreply, new_state}
  end

  def filter_event({:click, :run}, _, state) do
    {:stop, %{state | run_state: !state.run_state}}
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

  def modify_ui(state) do
    elapsed = Time.diff(Time.utc_now(), state.last_frame_time, :millisecond)

    g =
      state.graph
      |> Graph.modify(:frames, &text(&1, "#{elapsed} ms"))
      |> Graph.modify(:population, &text(&1, "#{Supervisor.count()}"))
      |> Graph.modify(:run, &button(&1, run_label(state.run_state)))

    %{state | graph: g, last_frame_time: Time.utc_now()}
  end

  def run_label(true), do: "Stop"
  def run_label(_), do: "Start"
end
