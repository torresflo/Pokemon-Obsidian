module Battle
  class Move
    # When Nature Power is used it turns into a different move depending on the current battle terrain.
    # @see https://pokemondb.net/move/nature-power
    # @see https://bulbapedia.bulbagarden.net/wiki/Nature_Power_(move)
    # @see https://www.pokepedia.fr/Force_Nature
    class NaturePower < Move
      include Mechanics::LocationBased

      private

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        skill = GameData::Skill[element_by_location]
        log_data("nature power # becomes #{skill.db_symbol}")

        move = Battle::Move[skill.be_method].new(skill.id, 1, 1, @scene)
        def move.usage_message(user)
          @scene.visual.hide_team_info
          scene.display_message_and_wait(parse_text(18, 127, '[VAR MOVE(0000)]' => name))
          PFM::Text.reset_variables
        end

        def move.move_usable_by_user(user, targets)
          return true
        end
        use_another_move(move, user)
      end

      # Element by location type.
      # @return [Hash<Symbol, Array<Symbol>]
      def element_table
        MOVES_TABLE
      end

      class << self
        def reset
          const_set(:MOVES_TABLE, {})
        end

        def register(loc, move)
          MOVES_TABLE[loc] ||= []
          MOVES_TABLE[loc] << move
          MOVES_TABLE[loc].uniq!
        end
      end

      reset
      register(:__undef__, :tri_attack)
      register(:building, :tri_attack)
      register(:grass, :energy_ball)
      register(:desert, :earth_power)
      register(:cave, :power_gem)
      register(:water, :hydro_pump)
      register(:shallow_water, :mud_bomb)
      register(:snow, :frost_breath)
      register(:icy_cave, :ice_beam)
      register(:volcanic, :lava_plume)
      register(:burial, :shadow_ball)
      register(:soaring, :air_slash)
      register(:misty_terrain, :moonblast)
      register(:grassy_terrain, :energy_ball)
      register(:electric_terrain, :thunderbolt)
      register(:psychic_terrain, :psychic)
      register(:space, :draco_meteor)
      register(:ultra_space, :psyshock)
    end
    Move.register(:s_nature_power, NaturePower)
  end
end
