module Battle
  class Move
    # Swallow recovers a varying amount of HP depending on how many times the user has used Stockpile.
    # @see https://pokemondb.net/move/swallow
    # @see https://bulbapedia.bulbagarden.net/wiki/Swallow_(move)
    # @see https://www.pokepedia.fr/Avale
    class Swallow < HealMove
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super

        unless targets.any? { |target| target.effects.has?(effect_name) || target.effects.get(effect_name)&.usable? }
          return show_usage_failure(user) && false
        end

        return true
      end

      private

      # Function that deals the heal to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, targets)
        targets.each do |target|
          effect = target.effects.get(effect_name)
          next unless effect&.usable?

          hp = target.max_hp * (ratio[effect.stockpile] || 0)
          log_error("Poorly configured moves, healed hp should be above zero. <stockpile:#{effect.stockpile}, ratios:#{ratio}") if hp <= 0
          log_data("# heal (swallow) #{hp}hp (stockpile:#{effect.stockpile}, ratio:#{ratio[effect.stockpile]}")
          if logic.damage_handler.heal(target, hp)
            effect.use
          end
        end
      end

      # Name of the effect
      # @return [Symbol]
      def effect_name
        :stockpile
      end

      # Healing value depending on stockpile
      # @return [Array]
      RATIO = [nil, 0.25, 0.5, 1]

      # Healing value depending on stockpile
      # @return [Array]
      def ratio
        RATIO
      end
    end
    Move.register(:s_swallow, Swallow)
  end
end
