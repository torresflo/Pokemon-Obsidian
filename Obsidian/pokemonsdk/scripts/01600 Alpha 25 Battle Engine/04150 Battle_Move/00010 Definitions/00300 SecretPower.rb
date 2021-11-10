module Battle
  class Move
    # Secret Power deals damage and has a 30% chance of inducing a secondary effect on the opponent, depending on the environment.
    # @see https://pokemondb.net/move/secret-power
    # @see https://bulbapedia.bulbagarden.net/wiki/Secret_Power_(move)
    # @see https://www.pokepedia.fr/Force_Cach%C3%A9e
    class SecretPower < BasicWithSuccessfulEffect
      include Mechanics::LocationBased

      private

      # Play the move animation
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      def play_animation(user, targets)
        @secret_power = element_by_location # Already tested as not nil
        mock_id = GameData::Skill.get_id(@secret_power.mock) if @secret_power.mock.is_a?(Symbol)
        mock = Move.new(mock_id, 1, 1, @scene)
        mock.send(:play_animation, user, targets)
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        return if logic.generic_rng.rand(100) > proc_chance

        actual_targets.each do |target|
          send(@secret_power.type, user, target, *@secret_power.params)
        end
      end

      # Change the target status
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @param status [Symbol]
      def sp_status(user, target, status)
        logic.status_change_handler.status_change_with_process(status, target, user, self)
      end

      # Change a stat
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @param stat [Symbol]
      # @param power [Integer]
      def sp_stat(user, target, stat, power)
        logic.stat_change_handler.stat_change_with_process(stat, power, target, user, self)
      end

      # Secret Power Card to pick
      class SPC
        attr_reader :mock, :type, :params

        # Create a new Secret Power possibility
        # @param mock [Symbol, Integer] ID or db_symbol of the animation move
        # @param type [Symbol] name of the function to call
        # @param params [Array<Object>] params to pass to the function
        def initialize(mock, type, *params)
          @mock = mock
          @type = type
          @params = params
        end

        def to_s
          "<SPC @mock=:#{@mock} @type=:#{@type} @params=#{@params}>"
        end
      end

      # Element by location type.
      # @return [Hash<Symbol, Array<Symbol>]
      def element_table
        SECRET_POWER_TABLE
      end

      # Chances of status/stat to proc out of 100
      # @return [Integer]
      def proc_chance
        30
      end

      class << self
        def reset
          const_set(:SECRET_POWER_TABLE, {})
        end

        # @param loc [Symbol] Name of the location type
        # @param mock [Symbol, Integer] ID or db_symbol of the move used for the animation
        # @param type [Symbol] name of the function to call
        # @param params [Array<Object>] params to pass to the function
        def register(loc, mock, type, *params)
          SECRET_POWER_TABLE[loc] ||= []
          SECRET_POWER_TABLE[loc] << SPC.new(mock, type, *params)
        end
      end

      reset
      register(:__undef__, :body_slam, :sp_status, :paralysis)
      register(:building, :body_slam, :sp_status, :paralysis)
      register(:grass, :vine_whip, :sp_status, :sleep)
      register(:desert, :mud_slap, :sp_stat, :acc, -1)
      register(:cave, :rock_throw, :sp_status, :flinch)
      register(:water, :water_pulse, :sp_stat, :atk, -1)
      register(:shallow_water, :mud_shot, :sp_stat, :spd, -1)
      register(:snow, :avalanche, :sp_status, :freezing)
      register(:icy_cave, :ice_shard, :sp_status, :freezing)
      register(:volcanic, :incinerate, :sp_status, :burn)
      register(:burial, :shadow_sneak, :sp_status, :flinch)
      register(:soaring, :gust, :sp_stat, :spd, -1)
      register(:misty_terrain, :fairy_wind, :sp_stat, :ats, -1)
      register(:grassy_terrain, :vine_whip, :sp_status, :sleep)
      register(:electric_terrain, :thunder_shock, :sp_status, :paralysis)
      register(:psychic_terrain, :confusion, :sp_stat, :spd, -1)
    end
    Move.register(:s_secret_power, SecretPower)
  end
end
