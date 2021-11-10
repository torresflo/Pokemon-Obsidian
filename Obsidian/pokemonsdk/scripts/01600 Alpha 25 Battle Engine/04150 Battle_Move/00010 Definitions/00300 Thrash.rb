module Battle
  class Move
    # Thrash Move
    class Thrash < BasicWithSuccessfulEffect
      private

      # Event called if the move failed
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @param reason [Symbol] why the move failed: :usable_by_user, :accuracy, :immunity
      def on_move_failure(user, targets, reason)
        user.effects.get(:force_next_move_disturbable)&.disturb
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        # @type [Effects::ForceNextMoveDisturbable]
        effect = user.effects.get(:force_next_move_disturbable)
        if effect
          if !effect.disturbed? && logic.status_change_handler.status_appliable?(:confusion, user, nil, self)
            logic.status_change_handler.status_change(:confusion, user)
          end
        else
          effect = Effects::ForceNextMoveDisturbable.new(logic, user, self, actual_targets, logic.generic_rng.rand(2..3))
          user.effects.replace(effect, &:force_next_move?)
        end
      end
    end

    Move.register(:s_thrash, Thrash)
    Move.register(:s_outrage, Thrash)
  end
end
