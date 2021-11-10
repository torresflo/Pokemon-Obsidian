module Battle
  class Move
    # Class managing the Psych Up move
    class PsychUp < Move
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false if targets.all? { |target| target.battle_stage.all?(&:zero?) }

        return true
      end

      # Test if the target is immune
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler]
      # @return [Boolean]
      def target_immune?(user, target)
        return true if target.effects.has?(:crafty_shield)

        return super
      end

      private

      # Check if the move bypass chance of hit and cannot fail
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Boolean]
      def bypass_chance_of_hit?(user, target)
        return true unless target.effects.has?(&:out_of_reach?)

        super
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          next if target.battle_stage.all?(&:zero?)

          target.battle_stage.each_with_index do |value, index|
            next if value == 0

            user.set_stat_stage(index, value)
          end
          @scene.display_message_and_wait(parse_text_with_pokemon(19, 1053, user, PFM::Text::PKNICK[1] => target.given_name))
        end
      end
    end
    Move.register(:s_psych_up, PsychUp)
  end
end
