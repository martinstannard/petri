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

    inner_state =
      %{
        creature: Messenger,
        viewport: viewport,
        count: 0,
        chain_length: 1,
        last_frame_time: Time.utc_now()
      }
    {nis, ng} = {inner_state, graph}
      |> Pause.init(%{})
      |> add_processes(7)

    {:ok, {nis, ng}, push: ng}
  end

  def handle_info(:animate, {inner_state, graph}) do
    nis = %{inner_state | last_frame_time: Time.utc_now()}
    {new_inner, new_graph} = draw({nis, graph})
    {:noreply, {new_inner, new_graph}, push: new_graph}
  end

  def handle_info(:update, {%{paused: true}, graph} = state) do
    {:noreply, state, push: graph}
  end

  def handle_info(:update, {inner_state, graph} = state) do
    send_ping(inner_state.chain_length)
    {:noreply, state, push: graph}
  end

  def handle_info(_, {_inner_state, graph} = state) do
    {:noreply, state, push: graph}
  end

  def filter_event({:click, :btn_row}, _, state) do
    {new_inner, new_graph} = add_processes(7, state)
    {:halt, {new_inner, new_graph}, push: new_graph}
  end

  def filter_event({:click, :ping}, _, {inner_state, _graph} = state) do
    send_ping(inner_state.chain_length)
    {new_inner_state, new_graph} = draw(state)
    {:halt, {new_inner_state, new_graph}, push: new_graph}
  end

  def filter_event({:click, :pause}, _, state) do
    new_state = state |> Pause.call
    {new_inner_state , new_graph} = draw(new_state)
    {:halt, {new_inner_state, new_graph}, push: new_graph}
  end

  def filter_event({:value_changed, :chain_length, count}, _, {inner_state, graph}) do
    ns = inner_state |> Map.put(:chain_length, count)

    {:halt, draw({ns, graph}), push: graph}
  end

  def add_processes(state, count) do
    state
    |> Birth.hatch_n(count)
  end

  def draw({inner_state, graph}) do
    new_graph =
      Supervisor.children()
      |> Enum.reduce(graph, &Messenger.draw(&1, &2))
      |> Graph.modify(:chain_length_text, &text(&1, "#{inner_state.chain_length}"))

    {inner_state, new_graph}
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
