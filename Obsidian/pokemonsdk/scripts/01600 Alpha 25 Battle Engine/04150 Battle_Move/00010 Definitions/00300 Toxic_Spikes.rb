module Battle
  class Move
    # Move that inflict Toxic Spikes to the enemy bank
    class ToxicSpikes < Move
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super

        return true
      end

      private

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        bank = actual_targets.map(&:bank).first

        # @type [Effects::ToxicSpikes]
        if (effect = @logic.bank_effects[bank]&.get(:toxic_spikes))
          effect.empower
        else
          @logic.add_bank_effect(Effects::ToxicSpikes.new(@logic, bank))
        end
        @scene.display_message_and_wait(parse_text(18, bank != 0 ? 159 : 158))
      end
    end

    Move.register(:s_toxic_spike, ToxicSpikes)
  end
end
