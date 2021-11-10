module Battle
  class Move
    # Move that inflict Stealth Rock to the enemy bank
    class StealthRock < Move
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super

        bank = targets.map(&:bank).first
        # @type [Effects::StealthRock]
        if @logic.bank_effects[bank]&.get(:stealth_rock)
          show_usage_failure(user)
          return false
        end
        return true
      end

      # Calculate the multiplier needed to get the damage factor of the Stealth Rock
      # @param target [PFM::PokemonBattler]
      # @return [Integer, Float]
      def calc_factor(target)
        type = [self.type]
        @effectiveness = -1
        n = calc_type_n_multiplier(target, :type1, type) *
            calc_type_n_multiplier(target, :type2, type) *
            calc_type_n_multiplier(target, :type3, type)
        return n
      end

      private

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        bank = actual_targets.map(&:bank).first
        @logic.add_bank_effect(Effects::StealthRock.new(@logic, bank, self))
        @scene.display_message_and_wait(parse_text(18, bank != 0 ? 163 : 162))
      end
    end

    Move.register(:s_stealth_rock, StealthRock)
  end
end
