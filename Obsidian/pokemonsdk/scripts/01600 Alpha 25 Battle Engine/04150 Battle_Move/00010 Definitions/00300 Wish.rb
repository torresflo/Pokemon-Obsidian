module Battle
  class Move
    # Move that setup a Wish that heals the Pokemon at the target's position
    class Wish < Move
      # Test if the effect is working
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      # @return [Boolean]
      def effect_working?(user, actual_targets)
        !actual_targets.all? { |target| logic.bank_effects[target.bank].has?(:wish) && logic.bank_effects[target.bank].get(:wish).position == target.position }
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          next if logic.bank_effects[target.bank].has?(:wish) && logic.bank_effects[target.bank].get(:wish).position == target.position

          logic.bank_effects[target.bank].add(Battle::Effects::Wish.new(logic, target.bank, target.position, target.max_hp / 2))
        end
      end
    end
    Move.register(:s_wish, Wish)
  end
end
