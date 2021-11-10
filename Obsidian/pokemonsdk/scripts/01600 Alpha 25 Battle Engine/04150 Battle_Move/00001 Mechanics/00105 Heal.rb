module Battle
  class Move
    # Class describing a heal move
    class HealMove < Move
      # Function that return the immunity
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] expected target
      def target_immune?(user, target)
        return true if super

        return db_symbol == :heal_pulse && target.effects.has?(:substitute)
      end

      # Function that deals the heal to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, targets)
        targets.each do |target|
          hp = target.max_hp / 2
          hp = hp * 3 / 2 if pulse? && user.has_ability?(:mega_launcher)
          logic.damage_handler.heal(target, hp)
        end
      end

      # Tell that the move is a heal move
      def heal?
        return true
      end
    end

    Move.register(:s_heal, HealMove)
  end
end
