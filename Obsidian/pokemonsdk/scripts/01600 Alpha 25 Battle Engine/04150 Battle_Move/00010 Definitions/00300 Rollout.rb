module Battle
  class Move
    # Move that is used during 5 turn and get more powerfull until it gets interrupted
    class Rollout < BasicWithSuccessfulEffect
      # Get the real base power of the move (taking in account all parameter)
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def real_base_power(user, target)
        # @type [Effects::Rollout]
        rollout_effect = user.effects.get(effect_name)
        mod = rollout_effect.successive_uses if rollout_effect
        mod = (mod || 0) + 1 if user.move_history.any? { |move| move.db_symbol == :defense_curl }
        return super * 2 ** (mod || 0)
      end

      private

      # Event called if the move failed
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @param reason [Symbol] why the move failed: :usable_by_user, :accuracy, :immunity
      def on_move_failure(user, targets, reason)
        user.effects.get(effect_name)&.kill
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        # @type [Effects::Rollout]
        rollout_effect = user.effects.get(effect_name)
        return rollout_effect.increase if rollout_effect

        effect = create_effect(user, actual_targets)
        user.effects.replace(effect, &:force_next_move?)
        effect.increase
      end

      # Name of the effect
      # @return [Symbol]
      def effect_name
        :rollout
      end

      # Create the effect
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      # @return [Effects::EffectBase]
      def create_effect(user, actual_targets)
        Effects::Rollout.new(logic, user, self, actual_targets, 5)
      end
    end

    # Ice Ball deals damage for 5 turns, doubling in power each turn. The move stops if it misses on any turn.
    # @see https://pokemondb.net/move/ice-ball
    # @see https://bulbapedia.bulbagarden.net/wiki/Ice_Ball_(move)
    # @see https://www.pokepedia.fr/Ball%27Glace
    class IceBall < Rollout
      # Return the chance of hit of the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Float]
      def chance_of_hit(user, target)
        # @type [Effects::Rollout]
        effect = user.effects.get(effect_name)
        return super unless effect

        # Acuracy lower 10% each use (90 -> 81 -> 73 -> 66 -> 57)
        result = (super * 0.9**effect.successive_uses).round
        log_data("chance of hit = #{result} # ice ball successive use : #{effect.successive_uses}")
        return result
      end
    end

    Move.register(:s_rollout, Rollout)
    Move.register(:s_ice_ball, IceBall)
  end
end
