module Battle
  class Move
    class HealingSacrifice < Move
      private

      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        unless @logic.can_battler_be_replaced?(user)
          show_usage_failure(user)
          return false
        end
        return true
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          add_effect(target)
          @scene.visual.show_hp_animations([target], [-target.hp])
          @logic.switch_request << { who: target }
        end
      end

      # Add the effect to the Pokemon
      # @param target [PFM::PokemonBattler]
      def add_effect(target)
        log_error('Move Implementation Error: add_effect should be overwritten in child class.')
      end
    end

    class HealingWish < HealingSacrifice
      # Add the effect to the Pokemon
      # @param target [PFM::PokemonBattler]
      def add_effect(target)
        target.effects.add(Effects::HealingWish.new(@logic, target))
      end
    end

    class LunarDance < HealingSacrifice
      # Add the effect to the Pokemon
      # @param target [PFM::PokemonBattler]
      def add_effect(target)
        target.effects.add(Effects::LunarDance.new(@logic, target))
      end
    end
    Move.register(:s_healing_wish, HealingWish)
    Move.register(:s_lunar_dance, LunarDance)
  end
end
