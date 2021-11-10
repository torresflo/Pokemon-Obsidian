module Battle
  class Move
    # Move that give a third type to an enemy
    class ChangeType < Move
      TYPES = {
        soak: GameData::Types::WATER
      }
      ABILITY_EXCEPTION = %i[multitype rks_system]
      # Test if the effect is working
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      # @return [Boolean]
      def effect_working?(user, actual_targets)
        if actual_targets.all? { |target| condition(target) }
          scene.display_message_and_wait(parse_text(18, 74))
          return false
        end
        return true
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          next if condition(target)

          target.effects.add(Battle::Effects::ChangeType.new(logic, target, new_type))
          scene.display_message_and_wait(message(target))
        end
      end

      # Method that tells if the Move's effect can proceed
      # @param target [PFM::PokemonBattler]
      # @return [Boolean]
      def condition(target)
        target.type_water? && target.type2 == 0 && target.type3 == 0 && ABILITY_EXCEPTION.include?(target.ability_db_symbol)
      end

      # Get the type given by the move
      # @return [Integer] the ID of the Type given by the move
      def new_type
        return TYPES[db_symbol] || 0
      end

      # Get the message text
      # @return [String]
      def message(target)
        return parse_text_with_pokemon(19, 899, target, '[VAR TYPE(0001)]' => GameData::Type[new_type].name)
      end
    end
    Move.register(:s_change_type, ChangeType)
  end
end
