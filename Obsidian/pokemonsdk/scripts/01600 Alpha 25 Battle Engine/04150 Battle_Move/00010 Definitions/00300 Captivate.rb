module Battle
  class Move
    # Class managing captivate move
    class Captivate < Move
      private

      # Ability preventing the move from working
      BLOCKING_ABILITY = %i[oblivious]
      # Test if the target is immune
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler]
      # @return [Boolean]
      def target_immune?(user, target)
        return true if user.gender == target.gender || target.gender == 0

        if user.can_be_lowered_or_canceled?(BLOCKING_ABILITY.include?(target.battle_ability_db_symbol))
          @scene.visual.show_ability(target)
          return true
        end

        return super
      end
    end

    Move.register(:s_captivate, Captivate)
  end
end
