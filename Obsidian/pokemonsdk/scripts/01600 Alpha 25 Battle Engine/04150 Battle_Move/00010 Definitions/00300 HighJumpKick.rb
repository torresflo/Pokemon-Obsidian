module Battle
  class Move
    # Move that has a big recoil when fails
    class HighJumpKick < Basic
      # Test move accuracy
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @return [Boolean] if the move can continue
      def proceed_move_accuracy(user, targets)
        accuracy_dice = logic.move_accuracy_rng.rand(100)
        log_data("# High Jump Kick: accuracy= #{accuracy}, value = #{accuracy_dice} (testing=#{accuracy > 0}, failure=#{accuracy_dice >= accuracy})")
        if (accuracy > 0 && accuracy_dice >= accuracy) || targets.all?(&:type_ghost?)
          scene.display_message_and_wait(parse_text(18, 74))
          hp = user.max_hp / 2
          scene.visual.show_hp_animations([user], [-hp])
          scene.display_message_and_wait(parse_text_with_pokemon(19, 908, user))
          return false
        end
        return true
      end

      # Test if the target is immune
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler]
      # @return [Boolean]
      def target_immune?(user, target)
        return false if target.type_ghost?
        return super
      end
    end
    Move.register(:s_jump_kick, HighJumpKick)
  end
end
