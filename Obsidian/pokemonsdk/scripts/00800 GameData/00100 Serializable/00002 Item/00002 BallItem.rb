module GameData
  # Item that allows to catch Pokemon in battle
  class BallItem < Item
    # Get the image of the ball
    # @return [String]
    attr_reader :img
    # Get the rate of the ball in worse conditions
    # @return [Integer, Float]
    attr_reader :catch_rate
    # Get the color of the ball
    # @return [Color]
    attr_reader :color
    # Create a new TechItem
    # @param initialize_params [Array] params to create the Item object
    # @param img [String] image of the ball
    # @param catch_rate [Integer] rate of the ball in worse conditions
    # @param color [Color] color of the ball
    def initialize(*initialize_params, img, catch_rate, color)
      super(*initialize_params)
      @img = img.to_s
      @catch_rate = catch_rate
      @color = color
    end
  end
end

safe_code('Register BallItem ItemDescriptor') do
  PFM::ItemDescriptor.define_chen_prevention(GameData::BallItem) do
    next !$game_temp.in_battle || $game_temp.trainer_battle || $game_switches[Yuki::Sw::BT_NoCatch]
  end
  PFM::ItemDescriptor.define_bag_use(GameData::BallItem, true) do |item, scene|
    battle_scene = scene.find_parent(Battle::Scene)
    if battle_scene.logic.alive_battlers(1).size > 1
      #TODO: Write text which says NO YOU CAN'T
      next :unused
    elsif battle_scene.player_actions.size > 1
      #TODO: Write text which says NO YOU CAN'T
      next :unused
    else
      GamePlay.bag_mixin.from(scene).battle_item_wrapper = PFM::ItemDescriptor.actions(item.id)
      #$scene = scene.__last_scene # This prevent the message from displaying now
      scene.return_to_scene(Battle::Scene)
    end
  end
  PFM::ItemDescriptor.define_chen_prevention(:rocket_ball) do
    next !$game_temp.in_battle || $game_switches[Yuki::Sw::BT_NoCatch]
  end
  PFM::ItemDescriptor.define_bag_use(:rocket_ball, true) do |item, scene|
    battle_scene = scene.find_parent(Battle::Scene)
    if battle_scene.logic.alive_battlers(1).size > 1
      #TODO: Write text which says NO YOU CAN'T
      next :unused
    elsif battle_scene.player_actions.size > 1
      #TODO: Write text which says NO YOU CAN'T
      next :unused
    else
      GamePlay.bag_mixin.from(scene).battle_item_wrapper = PFM::ItemDescriptor.actions(item.id)
      #$scene = scene.__last_scene # This prevent the message from displaying now
      scene.return_to_scene(Battle::Scene)
    end
  end
end
