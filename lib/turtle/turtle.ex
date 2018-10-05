defmodule Processor.Turtle do
  use GenServer

  alias Scenic.Graph

  import Scenic.Primitives

  @tri {{0, -20}, {10, 10}, {-10, 10}}
  @colors ~w(alice_blue antique_white aqua aquamarine azure beige bisque black blanched_almond blue blue_violet brown burly_wood cadet_blue chartreuse chocolate coral cornflower_blue cornsilk crimson cyan dark_blue dark_cyan dark_golden_rod dark_gray dark_grey dark_green dark_khaki dark_magenta dark_olive_green dark_orange dark_orchid dark_red dark_salmon dark_sea_green dark_slate_blue dark_slate_gray dark_slate_grey dark_turquoise dark_violet deep_pink deep_sky_blue dim_gray dim_grey dodger_blue fire_brick floral_white forest_green fuchsia gainsboro ghost_white gold golden_rod gray grey green green_yellow honey_dew hot_pink indian_red indigo ivory khaki lavender lavender_blush lawn_green lemon_chiffon light_blue light_coral light_cyan light_golden_rod_yellow light_gray light_grey light_green light_pink light_salmon light_sea_green light_sky_blue light_slate_gray light_slate_grey light_steel_blue light_yellow lime lime_green linen magenta maroon medium_aqua_marine medium_blue medium_orchid medium_purple medium_sea_green medium_slate_blue medium_spring_green medium_turquoise medium_violet_red midnight_blue mint_cream misty_rose moccasin navajo_white navy old_lace olive olive_drab orange orange_red orchid pale_golden_rod pale_green pale_turquoise pale_violet_red papaya_whip peach_puff peru pink plum powder_blue purple rebecca_purple red rosy_brown royal_blue saddle_brown salmon sandy_brown sea_green sea_shell sienna silver sky_blue slate_blue slate_gray slate_grey snow spring_green steel_blue tan teal thistle tomato turquoise violet wheat white white_smoke yellow yellow_green)a

  def start_link(id) do
    GenServer.start_link(__MODULE__, id)
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
        angle: Enum.random(200..800),
        velocity: Enum.random(0..100) / 20.0,
        x: Enum.random(0..800),
        y: Enum.random(0..800),
        color: Enum.random(@colors),
        tick: 0
      }
    }
  end

  def handle_cast(:update, state) do
    new_state =
      state
      |> right(Enum.random(-50..50) / state.angle)
      |> forward
      |> tick
      |> reverse
      |> colorize

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
          fill: {:color, state.color},
          scale: tick_scale(state)
        )
      )

    {:reply, g, state}
  end

  def tick(state) do
    %{state | tick: state.tick + 1}
  end

  def right(state, angle) do
    %{state | heading: state.heading - angle}
  end

  def forward(state) do
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

  # def calculators(state) do
  # end

  # def apply_calcs(state) do
  # end

  def tick_scale(state) do
    :math.sin(state.tick / 20.0) + 1.5
  end

  def reverse(state) do
    if :rand.uniform() < 0.01 do
      %{state | velocity: state.velocity * -1.0}
    else
      state
    end
  end

  def colorize(state) do
    if :rand.uniform() < 0.1 do
      %{state | color: Enum.random(@colors)}
    else
      state
    end
  end
end
