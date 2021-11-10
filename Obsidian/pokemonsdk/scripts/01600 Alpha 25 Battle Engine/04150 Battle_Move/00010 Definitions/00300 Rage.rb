module Battle
  class Move
    # Class managing moves that deal a status or flinch
    class Rage < BasicWithSuccessfulEffect
      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        return if user.effects.has?(:rage) && !user.effects.get(:rage).dead?

        user.effects.add(Effects::Rage.new(logic, user))
      end
    end

    Move.register(:s_rage, Rage)
  end
end
