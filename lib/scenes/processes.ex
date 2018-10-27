defmodule Petri.Scene.Processes do
  @moduledoc """
  A scene for displaying Processes
  """

  use Scenic.Scene
  import Scenic.Primitives, only: [{:text, 2}, {:text, 3}, {:rrect, 3}, {:update_opts, 2}]
  alias Scenic.Graph
  alias Petri.Component.{PetriUI, Nav}
  alias Petri.Creatures.{Messenger, Supervisor}
  alias Petri.Scenes.Behaviours.{Birth, Pause}

  @animate_ms 16
  @update_ms 2

  @graph Graph.build(font: :roboto, font_size: 14)
         |> text("0",
           id: :chain_length_text,
           translate: {20, 750},
           font_size: 40
         )

  def init(_, opts) do
    Supervisor.clear()
    viewport = opts[:viewport]

    graph =
      @graph
      |> Nav.add_to_graph(__MODULE__)
      |> PetriUI.add_to_graph(__MODULE__)

    {:ok, _} = :timer.send_interval(@animate_ms, :animate)
    {:ok, _} = :timer.send_interval(@update_ms, :update)

    state =
      %{
        creature: Messenger,
        viewport: viewport,
        graph: graph,
        count: 0,
        chain_length: 1,
        last_frame_time: Time.utc_now()
      }
      |> Pause.init(%{})

    {:ok, add_processes(7, state)}
  end

  def handle_info(:animate, state) do
    {:noreply, draw(%{state | last_frame_time: Time.utc_now()})}
  end

  def handle_info(:update, %{paused: true} = state) do
    {:noreply, state}
  end

  def handle_info(:update, state) do
    send_ping(state.chain_length)
    {:noreply, state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  def filter_event({:click, :btn_row}, _, state) do
    {:stop, add_processes(7, state)}
  end

  def filter_event({:click, :ping}, _, state) do
    send_ping(state.chain_length)
    {:stop, state}
  end

  def filter_event({:click, :pause}, _, state) do
    {:stop, state |> Pause.call() |> draw}
  end

  def filter_event({:value_changed, :chain_length, count}, _, state) do
    ns =
      state
      |> Map.put(:chain_length, count)

    {:stop, draw(ns)}
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
    graph =
      Supervisor.children()
      |> Enum.reduce(state.graph, &Messenger.draw(&1, &2))
      |> Graph.modify(:chain_length_text, &text(&1, "#{state.chain_length}"))
      |> push_graph

    %{state | graph: graph}
  end

  def send_ping(0), do: nil

  def send_ping(count) do
    Supervisor.random_child()
    |> pinger(count)
  end

  def pinger(nil, _), do: nil

  def pinger(child, count) do
    child |> Messenger.ping(count)
  end
end
