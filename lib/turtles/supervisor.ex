defmodule Processor.Turtles.Supervisor do
  def children do
    TurtleSupervisor
    |> DynamicSupervisor.which_children()
    |> Enum.map(fn t ->
      {_, pid, _, _} = t
      pid
    end)
  end

  def count do
    TurtleSupervisor
    |> DynamicSupervisor.which_children()
    |> length
  end

  def clear do
    children
    |> Enum.each(fn turtle ->
      DynamicSupervisor.terminate_child(TurtleSupervisor, turtle)
    end)
  end

  def apply(func) do
    children
    |> Enum.map(&apply(func, [&1]))
  end

  def random_child do
    children
    |> random()
  end

  defp random([]), do: nil

  defp random(children) do
    children
    |> Enum.random()
  end
end
