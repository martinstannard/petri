defmodule Processor.Creatures.Supervisor do
  def children do
    CreatureSupervisor
    |> DynamicSupervisor.which_children()
    |> Enum.map(fn t ->
      {_, pid, _, _} = t
      pid
    end)
  end

  def count do
    CreatureSupervisor
    |> DynamicSupervisor.which_children()
    |> length
  end

  def clear do
    children()
    |> Enum.each(fn turtle ->
      DynamicSupervisor.terminate_child(CreatureSupervisor, turtle)
    end)
  end

  def terminate(pid) do
    DynamicSupervisor.terminate_child(CreatureSupervisor, pid)
  end

  def apply(func) do
    children()
    |> Enum.map(&apply(func, [&1]))
  end

  def random_child do
    children()
    |> random()
  end

  defp random([]), do: nil

  defp random(childs) do
    childs
    |> Enum.random()
  end
end
