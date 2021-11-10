module Battle
  class Move
    # Mist move
    class Mist < Move
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super

        if logic.bank_effects[user.bank].has?(:mist)
          show_usage_failure(user)
          return false
        end

        return true
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.map(&:bank).uniq.each do |bank|
          logic.bank_effects[bank].add(Effects::Mist.new(logic, bank))
          scene.display_message_and_wait(parse_text(18, bank == 0 ? 142 : 143))
        end
      end
    end
    Move.register(:s_mist, Mist)
  end
end
