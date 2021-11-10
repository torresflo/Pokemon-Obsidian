module Battle
  class Move
    # Class managing Crafty Shield
    # Crafty Shield protects all Pokemon on the user bank from status moves
    class CraftyShield < Move
      private

      # Test if the target is immune
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler]
      # @return [Boolean]
      def target_immune?(user, target)
        return false
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        bank = actual_targets.map(&:bank).first
        actual_targets.each { |target| target.effects.add(Effects::CraftyShield.new(@logic, target)) }
        @scene.display_message_and_wait(parse_text(18, bank != 0 ? 212 : 211))
      end
    end

    Move.register(:s_crafty_shield, CraftyShield)
  end
end
