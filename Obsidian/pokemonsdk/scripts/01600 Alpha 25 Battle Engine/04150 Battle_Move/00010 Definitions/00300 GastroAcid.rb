module Battle
  class Move
    # Move that inflict leech seed to the ennemy
    class GastroAcid < Move
      private

      # Test if the target is immune
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler]
      # @return [Boolean]
      def target_immune?(user, target)
        return true if target.effects.has?(:ability_suppressed) || !@logic.ability_change_handler.can_change_ability?(target, :none)

        return super
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          target.effects.add(Effects::AbilitySuppressed.new(@logic, target))
          @scene.display_message_and_wait(parse_text_with_pokemon(19, 565, target))
        end
      end
    end

    Move.register(:s_gastro_acid, GastroAcid)
  end
end
