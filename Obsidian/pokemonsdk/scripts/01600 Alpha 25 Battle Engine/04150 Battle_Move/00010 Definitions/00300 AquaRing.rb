module Battle
  class Move
    # Class managing the Aqua Ring move
    class AquaRing < Move
      private

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          next if target.effects.has?(:aqua_ring)

          target.effects.add(Effects::AquaRing.new(@logic, target))
          @scene.display_message_and_wait(parse_text_with_pokemon(19, 601, target))
        end
      end
    end
    Move.register(:s_aqua_ring, AquaRing)
  end
end
