module Battle
  class Move
    # Move that inflict electrify to the ennemy
    class Electrify < Move
      private

      # Test if the target is immune
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler]
      # @return [Boolean]
      def target_immune?(user, target)
        return true if target.effects.has?(:change_type)

        return super
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          target.effects.add(Effects::Electrify.new(@logic, target))
          @scene.display_message_and_wait(parse_text_with_pokemon(19, 1195, target))
        end
      end
    end

    Move.register(:s_electrify, Electrify)
  end
end
