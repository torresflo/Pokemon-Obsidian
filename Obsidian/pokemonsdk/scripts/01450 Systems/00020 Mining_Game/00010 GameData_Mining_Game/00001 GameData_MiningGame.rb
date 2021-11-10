module GameData
  # Module that describes the Mining Game database and its derived methods
  module MiningGame
    module_function

    # Sign that indicate a part of the ITEM exist on a specific tile of a layout
    # @return true
    def x
      return true
    end

    # Sign that indicate a part of the ITEM does not exist on a specific tile of a layout
    # @return false
    def o
      return false
    end

    def register_item(db_symbol, probability, layout, accepted_max_rotation)
      DATA_ITEM[db_symbol] = {probability: probability, layout: layout, accepted_max_rotation: accepted_max_rotation}
    end

    def register_iron(symbol, probability, layout, accepted_max_rotation)
      DATA_IRON[symbol] = {probability: probability, layout: layout, accepted_max_rotation: accepted_max_rotation}
    end

    # The data list of each item that exist for the MiningGame
    # probability is an Integer and states how many chances out of the total of chances the item will be picked by the system.
    # layout is a [Array<Array>] where each sub-Array is assigned to one line; x means a part of the ITEM is here, o means that's not the case.
    # accepted_max_rotation is an Integer (between 0 and 3) determining the max rotation the sprite can have (90x degrees, x being accepted_max_rotation).
    DATA_ITEM = {}
    register_item(:blue_shard, 20, [[x,x,x],[x,x,x],[x,x,o]], 3)
    register_item(:green_shard, 20, [[x,x,x,x],[x,x,x,x],[x,x,o,x]], 3)
    register_item(:red_shard, 20, [[x,x,x],[x,x,o],[x,x,x]], 3)
    register_item(:yellow_shard, 20, [[x,o,x,o],[x,x,x,o],[x,x,x,x]], 3)
    register_item(:everstone, 1, [[x,x,x,x],[x,x,x,x]], 3)
    register_item(:dawn_stone, 1, [[x,x,x],[x,x,x],[x,x,x]], 3)
    register_item(:dusk_stone, 1, [[x,x,x],[x,x,x],[x,x,x]], 3)
    register_item(:fire_stone, 1, [[x,x,x],[x,x,x],[x,x,x]], 3)
    register_item(:ice_stone, 1, [[x,x,x],[x,x,x],[x,x,x]], 3)
    register_item(:leaf_stone, 1, [[o,x,o],[x,x,x],[x,x,x],[x,x,x]], 1)
    register_item(:moon_stone, 1, [[o,x,x,x],[x,x,x,o]], 1)
    register_item(:shiny_stone, 1, [[x,x,x],[x,x,x],[x,x,x]], 3)
    register_item(:sun_stone, 1, [[o,x,o],[x,x,x],[x,x,x]], 3)
    register_item(:thunder_stone, 1, [[o,x,x],[x,x,x],[x,x,o]], 3)
    register_item(:water_stone, 1, [[x,x,x],[x,x,x],[x,x,o]], 3)
    register_item(:damp_rock, 5, [[x,x,x],[x,x,x],[x,o,x]], 3)
    register_item(:hard_stone, 5, [[x,x],[x,x]], 0)
    register_item(:heart_scale, 20, [[x,o],[x,x]], 3)
    register_item(:heat_rock, 5, [[x,o,x,o],[x,x,x,x],[x,x,x,x]], 3)
    register_item(:icy_rock, 5, [[o,x,x,o],[x,x,x,x],[x,x,x,x],[x,o,o,x]], 3)
    register_item(:iron_ball, 5, [[x,x,x],[x,x,x],[x,x,x]], 0)
    register_item(:light_clay, 5, [[x,o,x,o],[x,x,x,o],[x,x,x,x],[o,x,o,x]], 3)
    register_item(:max_revive, 1, [[x,x,x],[x,x,x],[x,x,x]], 3)
    register_item(:odd_keystone, 1, [[x,x,x,x],[x,x,x,x],[x,x,x,x],[x,x,x,x]], 3)
    register_item(:rare_bone, 1, [[x,o,o,o,o,x],[x,x,x,x,x,x],[x,o,o,o,o,x]], 1)
    register_item(:revive, 5, [[o,x,o],[x,x,x],[o,x,o]], 1)
    register_item(:smooth_rock, 5, [[o,o,x,o],[x,x,x,o],[o,x,x,x],[o,x,o,o]], 3)
    register_item(:star_piece, 5, [[o,x,o],[x,x,x],[o,x,o]], 0)
    register_item(:draco_plate, 1, [[x,x,x,x],[x,x,x,x],[x,x,x,x]], 1)
    register_item(:dread_plate, 1, [[x,x,x,x],[x,x,x,x],[x,x,x,x]], 1)
    register_item(:earth_plate, 1, [[x,x,x,x],[x,x,x,x],[x,x,x,x]], 1)
    register_item(:fist_plate, 1, [[x,x,x,x],[x,x,x,x],[x,x,x,x]], 1)
    register_item(:flame_plate, 1, [[x,x,x,x],[x,x,x,x],[x,x,x,x]], 1)
    register_item(:icicle_plate, 1, [[x,x,x,x],[x,x,x,x],[x,x,x,x]], 1)
    register_item(:insect_plate, 1, [[x,x,x,x],[x,x,x,x],[x,x,x,x]], 1)
    register_item(:iron_plate, 1, [[x,x,x,x],[x,x,x,x],[x,x,x,x]], 1)
    register_item(:meadow_plate, 1, [[x,x,x,x],[x,x,x,x],[x,x,x,x]], 1)
    register_item(:mind_plate, 1, [[x,x,x,x],[x,x,x,x],[x,x,x,x]], 1)
    register_item(:pixie_plate, 1, [[x,x,x,x],[x,x,x,x],[x,x,x,x]], 1)
    register_item(:sky_plate, 1, [[x,x,x,x],[x,x,x,x],[x,x,x,x]], 1)
    register_item(:splash_plate, 1, [[x,x,x,x],[x,x,x,x],[x,x,x,x]], 1)
    register_item(:spooky_plate, 1, [[x,x,x,x],[x,x,x,x],[x,x,x,x]], 1)
    register_item(:stone_plate, 1, [[x,x,x,x],[x,x,x,x],[x,x,x,x]], 1)
    register_item(:toxic_plate, 1, [[x,x,x,x],[x,x,x,x],[x,x,x,x]], 1)
    register_item(:zap_plate, 1, [[x,x,x,x],[x,x,x,x],[x,x,x,x]], 1)
    register_item(:armor_fossil, 5, [[o,x,x,x,o],[o,x,x,x,o],[x,x,x,x,x],[o,x,x,x,o]], 3)
    register_item(:claw_fossil, 5, [[o,o,x,x],[o,x,x,x],[o,x,x,x],[x,x,x,o],[x,x,o,o]], 3)
    register_item(:dome_fossil, 5, [[x,x,x,x,x],[x,x,x,x,x],[x,x,x,x,x],[o,x,x,x,o]], 3)
    register_item(:helix_fossil, 5, [[o,x,x,x],[x,x,x,x],[x,x,x,x],[x,x,x,o]], 3)
    register_item(:old_amber, 5, [[o,x,x,x],[x,x,x,x],[x,x,x,x],[x,x,x,o]], 1)
    register_item(:root_fossil, 5, [[x,x,x,x,o],[x,x,x,x,x],[x,x,o,x,x],[o,o,o,x,x],[o,o,x,x,o]], 3)
    register_item(:skull_fossil, 5, [[x,x,x,x],[x,x,x,x],[x,x,x,x],[o,x,x,o]], 3)

    # The data list of each iron that exist for the MiningGame
    # probability is an Integer and states how many chances out of the total of chances the item will be picked by the system.
    # layout is a [Array<Array>] where each sub-Array is assigned to one line; x means a part of the ITEM is here, o means that's not the case.
    # accepted_max_rotation is an Integer (between 0 and 3) determining the max rotation the sprite can have (90x degrees, x being accepted_max_rotation).
    DATA_IRON = {}
    register_iron(:anti_stair, 20, [[x,o],[x,x],[o,x]], 1)
    register_iron(:big_square, 20, [[x,x,x],[x,x,x],[x,x,x]], 0)
    register_iron(:line, 20, [[x,x,x,x]], 1)
    register_iron(:rectangle, 20, [[x,x,x,x],[x,x,x,x]], 1)
    register_iron(:square, 20, [[x,x],[x,x]], 0)
    register_iron(:stair, 20, [[o,x],[x,x],[x,o]], 1)
    register_iron(:t_tetrimino, 20, [[o,x,o],[x,x,x]], 3)

    # Return the total of the chances to get a certain item
    # @return [Integer]
    def total_chance
      count = 0
      DATA_ITEM.each_key do |key|
        count += DATA_ITEM[key.to_sym][:probability]
      end
      return count
    end

    # Return the total of the chances to get a certain iron
    # @return [Integer]
    def iron_total_chance
      count = 0
      DATA_IRON.each_key do |key|
        count += DATA_IRON[key.to_sym][:probability]
      end
      return count
    end
  end
end
