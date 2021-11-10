module Battle
  module Actions
    # Class describing the Attack Action
    class Attack < Base
      # Get the move of this action
      # @return [Battle::Move]
      attr_reader :move
      # Get the user of this move
      # @return [PFM::PokemonBattler]
      attr_reader :launcher
      # Tell if pursuit on this action is enabled
      # @return [Boolean]
      attr_accessor :pursuit_enabled
      # Tell if this action can ignore speed of the other pokemon
      # @return [Boolean]
      attr_accessor :ignore_speed
      # List all the sub launcher that will use the same move due to their ability (Dancer)
      # @return [Array]
      attr_reader :sub_launchers
      # Create a new attack action
      # @param scene [Battle::Scene]
      # @param move [Battle::Move]
      # @param launcher [PFM::PokemonBattler]
      # @param target_bank [Integer] bank the move aims
      # @param target_position [Integer] position the move aims
      def initialize(scene, move, launcher, target_bank, target_position)
        super(scene)
        @move = move
        @launcher = launcher
        @target_bank = target_bank
        @target_position = target_position
        @pursuit_enabled = false
        @ignore_speed = false
        @sub_launchers = []
      end

      # Compare this action with another
      # @param other [Base] other action
      # @return [Integer]
      def <=>(other)
        return 1 if other.is_a?(HighPriorityItem)

        unless @pursuit_enabled && other.is_a?(Attack) && other.pursuit_enabled
          return -1 if @pursuit_enabled
          return 1 if other.is_a?(Attack) && other.pursuit_enabled
        end
        return -1 if other.is_a?(Flee) && move.relative_priority > 0
        return 1 unless other.is_a?(Attack)

        attack = Attack.from(other)
        return -1 if @ignore_speed && attack.move.priority(attack.launcher) == @move.priority(@launcher)

        priority_return = attack.move.priority(attack.launcher) <=> @move.priority(@launcher)
        return priority_return if priority_return != 0

        return -1 if (@launcher.hold_item?(:lagging_tail) && !attack.launcher.hold_item?(:lagging_tail)) ||
                     (@launcher.hold_item?(:full_incense) && !attack.launcher.hold_item?(:full_incense))
        return -1 if @launcher.has_ability?(:stall) && !attack.launcher.has_ability?(:stall)

        trick_room_factor = @scene.logic.terrain_effects.has?(:trick_room) ? -1 : 1
        return (attack.launcher.spd <=> @launcher.spd) * trick_room_factor
      end

      # Get the priority of the move
      # @return [Integer]
      def priority
        return @pursuit_enabled ? 999 : @move.priority
      end

      # Get the target of the move
      # @return [PFM::PokemonBattler, nil]
      def target
        targets = @move.battler_targets(@launcher, @scene.logic).select(&:alive?)
        best_target = targets.select { |battler| battler.position == @target_position && battler.bank == @target_bank }.first
        return best_target if best_target

        best_target = targets.select { |battler| battler.bank == @target_bank }.first
        return best_target || targets.first
      end

      # Execute the action
      def execute
        # Reset flee attempt count
        @scene.battle_info.flee_attempt_count = 0 if @launcher.from_party?
        @move.proceed(@launcher, @target_bank, @target_position)
        @sub_launchers.each do |launcher|
          @scene.visual.show_ability(launcher)
          @move.dup.proceed(launcher, @target_bank, @target_position)
        end
      end

      # Action describing the action forced by Encore
      class Encore < Attack
        # Execute the action
        def execute
          @scene.display_message_and_wait(parse_text_with_pokemon(19, 559, @launcher))
          @move.forced_next_move_decrease_pp = true
          super
          @move.forced_next_move_decrease_pp = false
          if @move.pp <= 0 && (effect = @launcher.effects.get(:encore))
            effect.kill
          end
        end
      end
    end
  end
end
