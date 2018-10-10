defmodule Processor.Turtles.Utils do
  def random_color do
    Enum.random(colors)
  end

  defp colors do
    ~w(alice_blue aqua aquamarine azure bisque black blue blue_violet brown burly_wood cadet_blue chartreuse chocolate coral cornflower_blue cornsilk crimson cyan deep_pink deep_sky_blue dodger_blue fire_brick forest_green fuchsia gainsboro gold golden_rod gray grey green green_yellow honey_dew hot_pink indian_red indigo ivory khaki lavender lavender_blush lawn_green lemon_chiffon lime lime_green linen magenta maroon medium_aqua_marine medium_blue medium_orchid medium_purple medium_sea_green medium_slate_blue medium_spring_green medium_turquoise medium_violet_red midnight_blue mint_cream misty_rose moccasin navy old_lace olive olive_drab orange orange_red orchid papaya_whip peach_puff peru pink plum powder_blue purple rebecca_purple red rosy_brown royal_blue saddle_brown salmon sandy_brown sea_green sea_shell sienna silver sky_blue slate_blue slate_gray slate_grey snow spring_green steel_blue tan teal thistle tomato turquoise violet wheat yellow yellow_green)a
  end
end

# 
