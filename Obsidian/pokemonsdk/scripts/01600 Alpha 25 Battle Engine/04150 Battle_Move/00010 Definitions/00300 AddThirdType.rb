module Battle
  class Move
    # Move that give a third type to an enemy
    class AddThirdType < Move
      TYPES = {
        trick_or_treat: GameData::Types::GHOST,
        forest_s_curse: GameData::Types::GRASS
      }
      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          target.type3 = new_type
          scene.display_message_and_wait(message(target))
        end
      end

      # Get the type given by the move
      # @return [Integer] the ID of the Type given by the move
      def new_type
        return TYPES[db_symbol] || 0
      end

      # Get the message text
      # @return [String]
      def message(target)
        return parse_text_with_pokemon(19, 902, target, '[VAR TYPE(0001)]' => GameData::Type[new_type].name)
      end
    end
    Move.register(:s_add_type, AddThirdType)
  end
end
