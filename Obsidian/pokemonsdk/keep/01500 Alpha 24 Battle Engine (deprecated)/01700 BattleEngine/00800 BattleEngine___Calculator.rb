module BattleEngine
  module_function

  # Calculate the type modifier
  # @param target [PFM::PokemonBattler24] target of the move
  # @param skill [Battle::Move] move that is currently used
  # @return [Float]
  def _type_modifier_calculation(target, skill)
    return skill.type_modifier(target, target)
  end

  # Calculate the damage dealt by the move
  # @param launcher [PFM::PokemonBattler24] user of the move
  # @param target [PFM::PokemonBattler24] target of the move
  # @param skill [Battle::Move] move that is currently used
  # @param params [Hash, nil] the parameters needed for the calculation
  # @return [Integer]
  # @note http://www.smogon.com/dp/articles/damage_formula#attack
  def _damage_calculation(launcher, target, skill, params = nil)
    return skill.damages(launcher, target, @move_damage_rng ||= Random.new)
  end
end
