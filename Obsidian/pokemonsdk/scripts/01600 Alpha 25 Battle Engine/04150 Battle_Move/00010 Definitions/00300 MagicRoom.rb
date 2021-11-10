module Battle
  class Move
    # Magic Room suppresses the effects of held items for all Pokémon for five turns.
    # @see https://pokemondb.net/move/magic-room
    # @see https://bulbapedia.bulbagarden.net/wiki/Magic_Room_(move)
    # @see https://www.pokepedia.fr/Zone_Magique
    class MagicRoom < Move
      private

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        if logic.terrain_effects.has?(:magic_room)
          logic.terrain_effects.get(:magic_room).kill
        else
          logic.terrain_effects.add(Effects::MagicRoom.new(logic, duration))
        end
      end

      # Duration of the effect
      # @return [Integer]
      def duration
        5
      end
    end
    register(:s_magic_room, MagicRoom)
  end
end
