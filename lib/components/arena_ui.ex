defmodule Processor.Component.ArenaUI do
  use Scenic.Component

  alias Scenic.ViewPort
  alias Scenic.Graph

  import Scenic.Primitives, only: [{:text, 3}]
  import Scenic.Components

  @height 110
  @font_size 20
  @indent 30

  # --------------------------------------------------------
  def verify(scene) when is_atom(scene), do: {:ok, scene}
  def verify({scene, _} = data) when is_atom(scene), do: {:ok, data}
  def verify(_), do: :invalid_data

  # ----------------------------------------------------------------------------
  def init(current_scene, opts) do
    # Get the viewport width
    {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} =
      opts[:viewport]
      |> ViewPort.info()

    graph =
      Graph.build(font_size: @font_size, translate: {0, vp_height - @height})
      # |> text("Turtles: ", id: :population, translate: {@indent, @font_size * 2})
      |> button("move",
        id: :move_food,
        theme: :primary,
        translate: {vp_width - 300, @font_size * 2}
      )
      |> button("+1",
        id: :btn_one,
        theme: :primary,
        translate: {vp_width - 200, @font_size * 2}
      )
      |> button("+10",
        id: :btn_ten,
        theme: :primary,
        translate: {vp_width - 100, @font_size * 2}
      )
      |> push_graph()

    {:ok, %{graph: graph, viewport: opts[:viewport]}}
  end
end
