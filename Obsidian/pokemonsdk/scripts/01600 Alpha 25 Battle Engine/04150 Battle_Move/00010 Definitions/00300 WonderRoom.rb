module Battle
  class Move
    # Wonder Room switches the Defense and Special Defense of all Pokémon in battle, for 5 turns.
    # @see https://pokemondb.net/move/wonder-room
    # @see https://bulbapedia.bulbagarden.net/wiki/Wonder_Room_(move)
    # @see https://www.pokepedia.fr/Zone_%C3%89trange/G%C3%A9n%C3%A9ration_6
    class WonderRoom < Move
      private

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        if logic.terrain_effects.has?(:wonder_room)
          logic.terrain_effects.get(:wonder_room)&.kill
        else
          logic.terrain_effects.add(Effects::WonderRoom.new(logic, actual_targets, duration))
        end
      end

      # Duration of the effect
      # @return [Integer]
      def duration
        5
      end
    end
    register(:s_wonder_room, WonderRoom)
  end
end
