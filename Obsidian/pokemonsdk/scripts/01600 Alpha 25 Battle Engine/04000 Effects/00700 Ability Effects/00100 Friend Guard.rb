module Battle
  module Effects
    class Ability
      class FriendGuard < Ability
        # Create a new FriendGuard effect
        # @param logic [Battle::Logic]
        # @param target [PFM::PokemonBattler]
        # @param db_symbol [Symbol] db_symbol of the ability
        def initialize(logic, target, db_symbol)
          super
          @affect_allies = true
        end

        # Get the base power multiplier of this move
        # @param user [PFM::PokemonBattler]
        # @param target [PFM::PokemonBattler]
        # @param move [Battle::Move]
        # @return [Float]
        def base_power_multiplier(user, target, move)
          return 1 if target.bank != self.target.bank
          return 1 unless user.can_be_lowered_or_canceled?

          return 0.75
        end
      end

      register(:friend_guard, FriendGuard)
    end
  end
end
