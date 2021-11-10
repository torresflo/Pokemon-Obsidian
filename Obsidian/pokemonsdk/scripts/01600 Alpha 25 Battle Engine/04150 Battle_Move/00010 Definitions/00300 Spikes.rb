module Battle
  class Move
    # Move that inflict Spikes to the enemy bank
    class Spikes < Move
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super

        bank = targets.map(&:bank).first
        # @type [Effects::Spikes]
        return true unless (effect = @logic.bank_effects[bank]&.get(:spikes))

        if effect.max_power?
          show_usage_failure(user)
          return false
        end

        return true
      end

      private

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        bank = actual_targets.map(&:bank).first

        # @type [Effects::Spikes]
        if (effect = @logic.bank_effects[bank]&.get(:spikes))
          effect.empower
        else
          @logic.add_bank_effect(Effects::Spikes.new(@logic, bank))
        end
        @scene.display_message_and_wait(parse_text(18, bank != 0 ? 155 : 154))
      end
    end

    Move.register(:s_spike, Spikes)
  end
end
