defmodule Processor.Arena.Birth do
  alias Processor.Turtle

  @moduledoc """
  give birth to new turtles
  """

  def call(state) do
    if :rand.uniform() < 0.01 do
      state
      |> hatch
    else
      state
    end
  end

  def hatch(state) do
    {:ok, process} = DynamicSupervisor.start_child(TurtleSupervisor, {Turtle, state.count})

    new_state = %{
      state
      | graph: Turtle.add_to_graph(process, state.graph),
        count: state.count + 1
    }

    # draw(new_state)
  end

  def hatch_n(state, count) do
    1..count
    |> Enum.reduce(state, fn _i, s ->
      hatch(s)
    end)
  end
end
