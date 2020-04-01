module GamePlay
  class BattleGrounds < Sprite
    GR_NAMES = %w[ground_building ground_grass ground_tall_grass ground_taller_grass ground_cave
                  ground_mount ground_sand ground_pond ground_sea ground_under_water ground_ice ground_snow]
    A_Pos = [nil, [88, 157 + 10], [99, 157 + 10], [99, 157 + 10]] # 1.5
    E_Pos = [nil, [233, 89], [233, 74], [233, 74]] # 1.3

    def initialize(viewport, actors = true)
      super(viewport)
      @actors = actors
      set_bitmap
      calibrate
    end

    def set_bitmap
      if $game_temp.battleback_name.to_s.empty?
        zone_type = $env.get_zone_type
        zone_type += 1 if zone_type > 0 || $env.grass?
        ground_name = GR_NAMES[zone_type].to_s
      else
        ground_name = $game_temp.battleback_name.sub('back_', 'ground_')
      end
      super(ground_name, :battleback)
      set_origin(bitmap.width / 2, bitmap.height / 2)
    end

    def calibrate
      arr = @actors ? A_Pos : E_Pos
      if $game_temp.vs_type == 2
        self.zoom = @actors ? 2 : 1.3
      elsif @actors
        self.zoom = 1.5 if $zoom_factor == 2
      end
      set_position(*arr[$game_temp.vs_type])
    end
  end
end
