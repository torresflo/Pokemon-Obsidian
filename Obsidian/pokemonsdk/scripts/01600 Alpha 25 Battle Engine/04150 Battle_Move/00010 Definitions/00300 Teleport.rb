module Battle
  class Move
    # Class managing Teleport move
    class Teleport < Move
      private
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def effect_working?(user, targets)
        return false if $game_switches[Yuki::Sw::BT_NoEscape]

        reason = @logic.battle_info.trainer_battle? ? :switch : :flee
        targets.any? do |target|
          return true if target.hold_item?(:smoke_ball)
          return false unless @logic.switch_handler.can_switch?(target, self, reason: reason)
        end
        return super
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          if @logic.battle_info.trainer_battle?
            @logic.switch_request << { who: target }
          else
            @battler_s = @scene.visual.battler_sprite(target.bank, target.position)
            @battler_s.flee_animation
            @logic.scene.visual.wait_for_animation
            scene.display_message_and_wait(parse_text_with_pokemon(19, 767, target))
            @logic.battle_result = 1
          end
        end
      end
    end

    Move.register(:s_teleport, Teleport)
  end
end
