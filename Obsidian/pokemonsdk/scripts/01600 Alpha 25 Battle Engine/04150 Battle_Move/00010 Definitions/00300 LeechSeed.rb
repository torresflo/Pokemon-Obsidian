module Battle
  class Move
    # Move that inflict leech seed to the ennemy
    class LeechSeed < Move
      private

      # Test if the target is immune
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler]
      # @return [Boolean]
      def target_immune?(user, target)
        return true if target.effects.has?(:leech_seed_mark) || target.type_grass? || target.effects.has?(:substitute)

        return super
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          @logic.add_position_effect(Effects::LeechSeed.new(@logic, user, target))
          @scene.display_message_and_wait(parse_text_with_pokemon(19, 607, target))
        end
      end
    end

    Move.register(:s_leech_seed, LeechSeed)
  end
end
