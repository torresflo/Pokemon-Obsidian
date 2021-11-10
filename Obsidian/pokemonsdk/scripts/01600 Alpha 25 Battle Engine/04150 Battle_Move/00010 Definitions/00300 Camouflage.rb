module Battle
  class Move
    # Camouflage causes the user to change its type based on the current terrain.
    # @see https://pokemondb.net/move/camouflage
    # @see https://bulbapedia.bulbagarden.net/wiki/Camouflage_(move)
    # @see https://www.pokepedia.fr/Camouflage
    class Camouflage < Move
      include Mechanics::LocationBased

      private

      # Play the move animation
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      def play_animation(user, targets)
        super # TODO, change the animation to match the type color
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        type = element_by_location
        actual_targets.each do |target|
          target.change_types(type)
          scene.display_message_and_wait(deal_message(user, target, type))
        end
      end

      def deal_message(user, target, type)
        parse_text_with_pokemon(19, 899, target, { '[VAR TYPE(0001)]' => GameData::Type[type].name })
      end

      # Element by location type.
      # @return [Hash<Symbol, Array<Symbol>]
      def element_table
        TYPE_BY_LOCATION
      end

      class << self
        def reset
          const_set(:TYPE_BY_LOCATION, {})
        end

        def register(loc, type)
          TYPE_BY_LOCATION[loc] ||= []
          TYPE_BY_LOCATION[loc] << GameData::Types.const_get(type)
          TYPE_BY_LOCATION[loc].uniq!
        end
      end

      reset
      register(:__undef__, :NORMAL)
      register(:building, :NORMAL)
      register(:grass, :GRASS)
      register(:desert, :GROUND)
      register(:cave, :ROCK)
      register(:water, :WATER)
      register(:shallow_water, :GROUND)
      register(:snow, :ICE)
      register(:icy_cave, :ICE)
      register(:volcanic, :FIRE)
      register(:burial, :GHOST)
      register(:soaring, :FLYING)
      register(:misty_terrain, :FAIRY)
      register(:grassy_terrain, :GRASS)
      register(:electric_terrain, :ELECTRIC)
      register(:psychic_terrain, :PSYCHIC)
      register(:space, :DRAGON)
      register(:ultra_space, :DRAGON)
    end
    register(:s_camouflage, Camouflage)
  end
end
