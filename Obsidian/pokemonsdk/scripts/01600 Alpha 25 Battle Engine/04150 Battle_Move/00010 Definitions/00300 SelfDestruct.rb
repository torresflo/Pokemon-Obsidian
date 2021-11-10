module Battle
  class Move
    # Move that execute Self-Destruct / Explosion
    class SelfDestruct < BasicWithSuccessfulEffect
      private

      # Event called if the move failed
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @param reason [Symbol] why the move failed: :usable_by_user, :accuracy, :immunity, :pp
      def on_move_failure(user, targets, reason)
        return false if reason != :immunity

        play_animation(user, targets)
        deal_effect(user, [])
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        logic.damage_handler.damage_change(user.hp, user)
      end
    end

    register(:s_explosion, SelfDestruct)
  end
end
