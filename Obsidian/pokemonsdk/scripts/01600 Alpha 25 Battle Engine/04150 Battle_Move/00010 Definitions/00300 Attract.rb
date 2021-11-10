module Battle
  class Move
    # Move that inflict attract effect to the ennemy
    class Attract < Move
      private

      # Ability preventing the move from working
      BLOCKING_ABILITY = %i[oblivious aroma_veil]
      # Test if the target is immune
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler]
      # @return [Boolean]
      def target_immune?(user, target)
        return true if target.effects.has?(:attract) || (user.gender * target.gender) != 2

        ally = @logic.allies_of(target).find { |a| BLOCKING_ABILITY.include?(a.battle_ability_db_symbol) }
        if target.hold_item?(:mental_herb)
          @logic.item_change_handler.change_item(:none, true, target)
          return true
        elsif user.can_be_lowered_or_canceled?(BLOCKING_ABILITY.include?(target.battle_ability_db_symbol))
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
          target.effects.add(Effects::Attract.new(@logic, target, user))
          user.effects.add(Effects::Attract.new(@logic, user, target)) if target.hold_item?(:destiny_knot)
        end
      end
    end

    Move.register(:s_attract, Attract)
  end
end
