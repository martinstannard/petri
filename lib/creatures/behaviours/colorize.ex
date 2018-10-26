defmodule Processor.Creatures.Behaviour.Colorize do
  @moduledoc """
  changes a turtle's color
  """

  @colors ~w(alice_blue antique_white aqua aquamarine azure beige bisque black blanched_almond blue blue_violet brown burly_wood cadet_blue chartreuse chocolate coral cornflower_blue cornsilk crimson cyan dark_blue dark_cyan dark_golden_rod dark_gray dark_grey dark_green dark_khaki dark_magenta dark_olive_green dark_orange dark_orchid dark_red dark_salmon dark_sea_green dark_slate_blue dark_slate_gray dark_slate_grey dark_turquoise dark_violet deep_pink deep_sky_blue dim_gray dim_grey dodger_blue fire_brick floral_white forest_green fuchsia gainsboro ghost_white gold golden_rod gray grey green green_yellow honey_dew hot_pink indian_red indigo ivory khaki lavender lavender_blush lawn_green lemon_chiffon light_blue light_coral light_cyan light_golden_rod_yellow light_gray light_grey light_green light_pink light_salmon light_sea_green light_sky_blue light_slate_gray light_slate_grey light_steel_blue light_yellow lime lime_green linen magenta maroon medium_aqua_marine medium_blue medium_orchid medium_purple medium_sea_green medium_slate_blue medium_spring_green medium_turquoise medium_violet_red midnight_blue mint_cream misty_rose moccasin navajo_white navy old_lace olive olive_drab orange orange_red orchid pale_golden_rod pale_green pale_turquoise pale_violet_red papaya_whip peach_puff peru pink plum powder_blue purple rebecca_purple red rosy_brown royal_blue saddle_brown salmon sandy_brown sea_green sea_shell sienna silver sky_blue slate_blue slate_gray slate_grey snow spring_green steel_blue tan teal thistle tomato turquoise violet wheat white white_smoke yellow yellow_green)a

  def init(state, _opts \\ %{}) do
    state
    |> Map.put(:color_trigger, Enum.random(1..10) / 100.0)
  end

  def call(state, _) do
    if :rand.uniform() < state.color_trigger do
      %{state | color: Enum.random(@colors)}
    else
      state
    end
  end
end
