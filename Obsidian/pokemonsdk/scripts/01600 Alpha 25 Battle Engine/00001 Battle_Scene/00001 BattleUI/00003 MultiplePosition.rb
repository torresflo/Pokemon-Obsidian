module BattleUI
  # Module helping to position any sprite that can get several positions depending on the battle mode
  #
  # All class including this module should define the following methods
  #   - `scene` that returns the current Battle Scene
  #   - `position` that returns the position of the current object in its bank (0, 1, 2, ...)
  #   - `bank` that returns the bank of the current object (0 = ally, 1 = enemies)
  #   - `base_position_v1` that returns the base position of the object in 1v1 battles
  #   - `base_position_v2` that returns the base position of the object in 2v2+ battles
  #   - `offset_position_v2` that returns the offset of the object depending on its bank (this offset is multiplied to position)
  #
  # This module will define a `sprite_position` function that will compute the x & y position this element should get
  module MultiplePosition
    # @!method scene
    #   Get the battle scene to access all information
    #   @return [Battle::Scene]
    # @!method position
    #   Get the object position in the bank
    #   @return [Integer]
    # @!method bank
    #   Get the object bank
    #   @return [Integer]
    # @!method base_position_v1
    #   Get the position of the object (depeding on enemy?) in 1v1 battle
    #   @return [Array(Integer, Integer)]
    # @!method base_position_v2
    #   Get the position of the object (depending on enemy?) in 2v2+ battle
    #   @return [Array(Integer, Integer)]
    # @!method offset_position_v2
    #   Get the offset factor of the object (depending on enemy?) this will be multiplied to position

    # Tell if the sprite is from the enemy side
    # @return [Boolean]
    def enemy?
      return bank == 1
    end

    private

    # Get the sprite position
    # @return [Array(Integer, Integer)]
    def sprite_position
      if scene.battle_info.vs_type == 1
        x, y = base_position_v1
      else
        x, y = base_position_v2
        dx, dy = offset_position_v2
        x += dx * position
        y += dy * position
      end
      return x, y
    end
  end
end
