module Battle
  class Move
    # Class managing the Topsy-Turvy move
    class TopsyTurvy < Move
      private

      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false if targets.all? { |target| target.battle_stage.all?(&:zero?) }

        return true
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          next if target.battle_stage.all?(&:zero?)

          target.battle_stage.each_with_index do |value, index|
            next if value == 0

            target.set_stat_stage(index, -value)
          end
          @scene.display_message_and_wait(parse_text_with_pokemon(19, 1177, target))
        end
      end
    end
    Move.register(:s_topsy_turvy, TopsyTurvy)
  end
end
