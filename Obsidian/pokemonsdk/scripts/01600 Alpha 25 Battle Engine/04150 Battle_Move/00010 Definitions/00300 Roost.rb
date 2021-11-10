module Battle
  class Move
    class Roost < HealMove
      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          hp = target.max_hp / 2
          target.effects.add(Effects::Roost.new(@logic, target, turn_count)) if logic.damage_handler.heal(target, hp)
        end
      end

      # Return the number of turns the effect works
      # @return Integer
      def turn_count
        return 1
      end
    end
    Move.register(:s_roost, Roost)
  end
end
