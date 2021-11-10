module Battle
  class Move
    # Taunt move
    class Taunt < Move
      # Ability preventing the move from working
      BLOCKING_ABILITY = %i[oblivious aroma_veil]

      # Test if the target is immune
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler]
      # @return [Boolean]
      def target_immune?(user, target)
        return true if target.effects.has?(:taunt)

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
          message = parse_text_with_pokemon(19, 568, target)
          target.effects.add(Effects::Taunt.new(@logic, target))
          @scene.display_message_and_wait(message)
        end
      end
    end
    Move.register(:s_taunt, Taunt)
  end
end
