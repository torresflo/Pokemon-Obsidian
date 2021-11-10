# Class in charge of generating random numbers
#
# Here PSDK will store constants to make separate random generators
class Random
  # WILD_BATTLE random generator
  WILD_BATTLE = new
  # IV hp random generator
  IV_HP = new
  # IV atk random generator
  IV_ATK = new
  # IV dfe random generator
  IV_DFE = new
  # IV spd random generator
  IV_SPD = new
  # IV ats random generator
  IV_ATS = new
  # IV dfs random generator
  IV_DFS = new
  # Mining Game's items random generator
  MINING_GAME_ITEM = new
  # Mining Game's tiles random generator
  MINING_GAME_TILES = new
  # Mining Game's obstacles random generator
  MINING_GAME_OBSTACLES = new
end

class Object
  # Attempt to get for the battles
  # @param rate [Float] number between 0 & 1 telling how much chance we have
  # @param logic [Battle::Logic]
  # @return [Boolean]
  def bchance?(rate, logic = nil)
    logic ||= (@logic || ($scene.is_a?(Battle::Scene) ? $scene.logic : nil))
    raise 'bchance? called outside of Battle!' unless logic

    return logic.generic_rng.rand < rate
  end
end
