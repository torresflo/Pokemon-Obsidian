module Battle
  class Move
    # Abstract class that manage logic of stage swapping moves
    class StatAndStageEdit < Move
      private

      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super
        return show_usage_failure(user) && false if targets.all? { |target| target.effects.has?(&:out_of_reach?) }

        return true
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          next if target.effects.has?(&:out_of_reach?)

          edit_stages(user, target)
        end
        return true
      end

      # Apply the stats or/and stage edition
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler]
      def edit_stages(user, target)
        log_error('Poorly implemented move: edit_stages(user, target) should have been overwritten in child class.')
      end
    end

    # Abstract class that manage logic of stage swapping moves and bypass accuracy calculation
    class StatAndStageEditBypassAccuracy < StatAndStageEdit
      # Tell if the move accuracy is bypassed
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @return [Boolean]
      def bypass_accuracy?(user, targets)
        return true
      end
    end
  end
end
