defmodule Petri.Component.PetriUI do
  use Scenic.Component

  alias Scenic.ViewPort
  alias Scenic.Graph

  # import Scenic.Primitives, only: [{:text, 3}]
  import Scenic.Components

  @height 110
  @font_size 20

  # --------------------------------------------------------
  def verify(scene) when is_atom(scene), do: {:ok, scene}
  def verify({scene, _} = data) when is_atom(scene), do: {:ok, data}
  def verify(_), do: :invalid_data

  # ----------------------------------------------------------------------------
  def init(_current_scene, opts) do
    # Get the viewport width
    {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} =
      opts[:viewport]
      |> ViewPort.info()

    graph =
      Graph.build(font_size: @font_size, translate: {0, vp_height - @height})
      |> button("Ping",
        id: :ping,
        theme: :secondary,
        translate: {vp_width - 200, @font_size * 2}
      )
      |> button("Add Row",
        id: :btn_row,
        theme: :secondary,
        translate: {vp_width - 100, @font_size * 2}
      )
      |> slider({{1, 20}, 1},
        id: :chain_length,
        translate: {vp_width - 700, @font_size * 2 + 10}
      )
      |> push_graph()

    {:ok, %{graph: graph, viewport: opts[:viewport]}}
  end
end
