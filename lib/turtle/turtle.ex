defmodule Processor.Turtle do
  use GenServer

  alias Scenic.Graph

  import Scenic.Primitives

  @tri {{0, -20}, {10, 10}, {-10, 10}}

  @colors ~w(red green blue yellow orange brown violet purple plum olive navy silver sienna tan teal thistle tomato orchid hot_pink gold golden_rod fuchsia dodger_blue indigo magenta maroon)a

  def start(id) do
    GenServer.start_link(__MODULE__, id)
  end

  def turn(pid, angle) do
    GenServer.call(pid, {:turn, angle})
  end

  def fd(pid, distance) do
    GenServer.call(pid, {:fd, distance})
  end

  def state(pid) do
    GenServer.call(pid, :state)
  end

  def update(pid) do
    GenServer.cast(pid, :update)
  end

  def draw(pid, graph) do
    GenServer.call(pid, {:draw, graph})
  end

  def init(id) do
    {
      :ok,
      %{
        id: id,
        heading: Enum.random(0..628) / 100.0,
        velocity: Enum.random(0..100) / 10.0,
        x: Enum.random(0..800),
        y: Enum.random(0..800),
        color: Enum.random(@colors)
      }
    }
  end

  def handle_cast(:update, state) do
    new_state =
      state
      |> right(Enum.random(-100..100) / 600.0)
      |> forward(state.velocity)

    {:noreply, new_state}
  end

  def handle_call({:draw, graph}, _, state) do
    g =
      graph
      |> Graph.modify(
        state.id,
        &triangle(&1, @tri,
          translate: {state.x, state.y},
          rotate: state.heading,
          fill: {:color, state.color}
        )
      )

    new_state = %{
      state
      | graph: g
    }

    {:reply, g, state}
  end

  def handle_call(:state, _, state) do
    {:reply, state, state}
  end

  def handle_call({:turn, angle}, _, state) do
    new_state = right(state, angle)
    {:reply, new_state, new_state}
  end

  def handle_call({:fd, distance}, _, state) do
    new_state = forward(state, distance)
    {:reply, new_state, new_state}
  end

  def right(state, angle) do
    %{state | heading: state.heading - angle}
  end

  def forward(state, distance) do
    %{
      state
      | x: new_x(state.x, state.heading, state.velocity),
        y: new_y(state.y, state.heading, state.velocity)
    }
  end

  defp new_x(x, heading, distance) do
    new_x = x + :math.sin(heading) * distance
    bound(new_x)
  end

  defp new_y(y, heading, distance) do
    new_y = y - :math.cos(heading) * distance
    bound(new_y)
  end

  def bound(coord) when coord > 800.0, do: coord - 800.0
  def bound(coord) when coord < 0.0, do: coord + 800.0
  def bound(coord), do: coord
end
