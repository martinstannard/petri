defmodule Utils.Modular do
  @moduledoc """
  helper functions for modules used in scenes and creatures
  """

  def init_modules(state, modules, opts \\ %{}) do
    modules
    |> Enum.reduce(state, fn m, s ->
      s |> m.init(opts)
    end)
  end

  def call_modules(state, modules, world) do
    modules
    |> Enum.reduce(state, fn m, s ->
      s |> m.call(world)
    end)
  end

  def call_modules(state, modules) do
    modules
    |> Enum.reduce(state, fn m, s ->
      s |> m.call
    end)
  end
end
