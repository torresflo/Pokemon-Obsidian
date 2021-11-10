module Battle
  class Move
    # Class managing fixed damages moves
    class FixedDamages < Basic
      FIXED_DMG_PARAM = {
        sonic_boom: 20,
        dragon_rage: 40
      }

      # Method calculating the damages done by the actual move
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def damages(user, target)
        @critical = false
        @effectiveness = 1
        dmg = FIXED_DMG_PARAM[db_symbol]
        log_data("Fixed Damages Move: #{dmg} HP")
        return dmg || 1
      end
    end

    Move.register(:s_fixed_damage, FixedDamages)
  end
end
