defmodule Processor.Turtle do
  use GenServer

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

  def init(id) do
    {
      :ok,
      %{
        id: id,
        heading: 0.0,
        velocity: 0.0,
        x: Enum.random(0..500),
        y: Enum.random(0..500)
      }
    }
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
    %{state | heading: state.heading + angle}
  end

  def forward(state, distance) do
    %{state | x: state.x + distance, y: state.y + distance}
  end
end
