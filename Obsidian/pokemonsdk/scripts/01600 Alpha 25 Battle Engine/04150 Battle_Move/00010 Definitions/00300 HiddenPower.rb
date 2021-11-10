module Battle
  class Move
    # Hidden Power deals damage, however its type varies for every Pokémon, depending on that Pokémon's Individual Values (IVs).
    # @see https://pokemondb.net/move/hidden-power
    # @see https://bulbapedia.bulbagarden.net/wiki/Hidden_Power_(move)
    # @see https://www.pokepedia.fr/Puissance_Cach%C3%A9e
    # @see https://bulbapedia.bulbagarden.net/wiki/Hidden_Power_(move)/Calculation
    class HiddenPower < Basic
=begin
      # Since Gen 6, Hidden Power's power is always 60. Uncomment this to revert to older generation...

      # Get the real base power of the move (taking in account all parameter)
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def real_base_power(user, target)
        power = 0
        iv_list.each_with_index { |iv, i| index += (user.send(iv) % 4 >= 2 ? 1 : 0) * 2 ** i }
        power = (power * 40 / 63 + 30).floor
        log_data("power = #{power} # Hidden power calc")
        return power
      end
=end

      # Get the types of the move with 1st type being affected by effects
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Array<Integer>] list of types of the move
      def definitive_types(user, target)
        index = 0
        iv_list.each_with_index { |iv, i| index += (user.send(iv) & 1) * 2 ** i }
        index = (index * (types_table.length - 1) / 63).floor
        type_id = types_table[index]
        log_data("Hidden power : internal index=#{index} > GameData::Types::#{GameData::Type[type_id].name.upcase}")
        return [type_id]
      end

      private

      # Hidden power move types
      # @return [Array<Integer>] array of types
      TYPES_TABLE = [
        GameData::Types::FIGHTING,
        GameData::Types::FLYING,
        GameData::Types::POISON,
        GameData::Types::GROUND,
        GameData::Types::ROCK,
        GameData::Types::BUG,
        GameData::Types::GHOST,
        GameData::Types::STEEL,
        GameData::Types::FIRE,
        GameData::Types::WATER,
        GameData::Types::GRASS,
        GameData::Types::ELECTRIC,
        GameData::Types::PSYCHIC,
        GameData::Types::ICE,
        GameData::Types::DRAGON,
        GameData::Types::DARK
      ]

      # Hidden power move types
      # @return [Array<Integer>] array of types
      def types_table
        return TYPES_TABLE
      end

      # IVs weighted from the litest to the heaviest in type / damage calculation
      # @return [Array<Symbol>]
      IV_LIST = %i[iv_hp iv_atk iv_dfe iv_spd iv_ats iv_dfs]
      # IVs weighted from the litest to the heaviest in type / damage calculation
      # @return [Array<Symbol>]
      def iv_list
        return IV_LIST
      end
    end
    Move.register(:s_hidden_power, HiddenPower)
  end
end
