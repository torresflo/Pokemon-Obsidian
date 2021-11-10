module Battle
  class Move
    # Class managing moves that force the target switch
    # Roar, Whirlwind, Dragon Tail, Circle Throw
    class ForceSwitch < BasicWithSuccessfulEffect
      # Tell if the move is a move that forces target switch
      # @return [Boolean]
      def force_switch?
        return true
      end

      private

      # Test if the target is immune
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler]
      # @return [Boolean]
      def target_immune?(user, target)
        return true if target.effects.has?(:crafty_shield) && be_method == :s_roar

        return super
      end

      # Check if the move bypass chance of hit and cannot fail
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Boolean]
      def bypass_chance_of_hit?(user, target)
        return true unless target.effects.has?(&:out_of_reach?) && be_method == :s_roar

        super
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          next false unless @logic.switch_handler.can_switch?(target, self) && user.alive?
          next false if target.effects.has?(:substitute) && be_method == :s_dragon_tail

          if !@logic.battle_info.trainer_battle? && @logic.alive_battlers_without_check(target.bank).size == 1 && target.bank == 1 && user.level >= target.level && !$game_switches[Yuki::Sw::BT_NoEscape]
            @battler_s = @scene.visual.battler_sprite(target.bank, target.position)
            @battler_s.flee_animation
            @logic.scene.visual.wait_for_animation
            @logic.battle_result = 1
          end
          rand_pkmn = (@logic.alive_battlers_without_check(target.bank).select { |p| p if p.party_id == target.party_id && p.position == -1 }).compact
          @logic.actions.reject! { |a| a.is_a?(Actions::Attack) && a.launcher == target }
          @logic.switch_request << { who: target, with: rand_pkmn.sample } unless rand_pkmn.empty?
        end
      end
    end

    Move.register(:s_dragon_tail, ForceSwitch)
    Move.register(:s_roar, ForceSwitch)
  end
end
