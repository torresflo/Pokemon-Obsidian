module Battle
  class Move
    # Move that resets stats of all pokemon on the field
    class Haze < BasicWithSuccessfulEffect
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super
        return true if db_symbol != :haze

        if targets.none? { |target| target.battle_stage.any? { |stage| stage != 0 } }
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
        actual_targets.each do |target|
          next if target.battle_stage.none? { |stage| stage != 0 }

          target.battle_stage.map! { 0 }
          scene.display_message_and_wait(parse_text_with_pokemon(19, 195, target))
        end
      end
    end

    Move.register(:s_haze, Haze)
  end
end
