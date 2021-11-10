module Battle
  class Move
    # Class managing Rapid Spin move
    class RapidSpin < BasicWithSuccessfulEffect
      private

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        user.effects.each { |e| e.kill if e.rapid_spin_affected? }
        logic.bank_effects[user.bank].each { |e| e.kill if e.rapid_spin_affected? }
      end
    end

    Move.register(:s_rapid_spin, RapidSpin)
  end
end
