module Battle
  class Move
    # Move that makes possible to hit Ghost type Pokemon with Normal or Fighting type moves
    class Nightmare < Move
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super

        if targets.all? { |target| target.effects.has?(:nightmare) }
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
          next if target.effects.has?(:nightmare)

          target.effects.add(Effects::Nightmare.new(@logic, target))
          @scene.display_message_and_wait(parse_text_with_pokemon(19, 321, target))
        end
      end
    end

    Move.register(:s_nightmare, Nightmare)
  end
end
