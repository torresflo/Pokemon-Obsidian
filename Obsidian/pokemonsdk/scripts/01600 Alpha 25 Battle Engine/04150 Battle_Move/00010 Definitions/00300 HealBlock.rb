module Battle
  class Move
    # Move that rectricts the targets from healing in certain ways for five turns
    class HealBlock < Move
      # Ability preventing the move from working
      BLOCKING_ABILITY = %i[aroma_veil]

      private

      # Test if the target is immune
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler]
      # @return [Boolean]
      def target_immune?(user, target)
        ally = @logic.allies_of(target).find { |a| BLOCKING_ABILITY.include?(a.battle_ability_db_symbol) }
        if user.can_be_lowered_or_canceled?(BLOCKING_ABILITY.include?(target.battle_ability_db_symbol))
          @scene.visual.show_ability(target)
          return true
        elsif user.can_be_lowered_or_canceled? && ally
          @scene.visual.show_ability(ally)
          return true
        end

        return super
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          target.effects.add(Effects::HealBlock.new(@logic, target))
          @scene.display_message_and_wait(parse_text_with_pokemon(19, 884, target))
        end
      end
    end

    Move.register(:s_heal_block, HealBlock)
  end
end
