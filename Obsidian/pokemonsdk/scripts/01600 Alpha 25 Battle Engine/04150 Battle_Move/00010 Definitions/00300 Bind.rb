module Battle
  class Move
    # Move that binds the target to the field
    class Bind < Basic
      private

      # Test if the effect is working
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      # @return [Boolean]
      def effect_working?(user, actual_targets)
        actual_targets.any? { |target| !target.effects.has?(:bind) }
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        turn_count = user.hold_item?(:grip_claw) ? 7 : logic.generic_rng.rand(4..5)
        actual_targets.each do |target|
          next if target.effects.has?(:bind)

          target.effects.add(Effects::Bind.new(logic, target, user, turn_count, self))
        end
      end
    end

    Move.register(:s_bind, Bind)
  end
end
