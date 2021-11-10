module Battle
  class Move
    # Function that tests if the user is able to use the move
    # @param user [PFM::PokemonBattler] user of the move
    # @param targets [Array<PFM::PokemonBattler>] expected targets
    # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
    # @return [Boolean] if the procedure can continue
    def move_usable_by_user(user, targets)
      log_data("# move_usable_by_user(#{user}, #{targets})")
      PFM::Text.set_variable(PFM::Text::PKNICK[0], user.given_name)
      PFM::Text.set_variable(PFM::Text::MOVE[1], name)
      exec_hooks(Move, :move_prevention_user, binding)
      return true
    rescue Hooks::ForceReturn => e
      log_data("# FR: move_usable_by_user #{e.data} from #{e.hook_name} (#{e.reason})")
      return e.data
    ensure
      PFM::Text.reset_variables
    end

    # Function that tells if the move is disabled
    # @param user [PFM::PokemonBattler] user of the move
    # @return [Boolean]
    def disabled?(user)
      disable_reason(user) ? true : false
    end

    # Get the reason why the move is disabled
    # @param user [PFM::PokemonBattler] user of the move
    # @return [#call] Block that should be called when the move is disabled
    def disable_reason(user)
      return proc {} if pp == 0

      exec_hooks(Move, :move_disabled_check, binding)
      return nil
    rescue Hooks::ForceReturn => e
      log_data("# disable_reason(#{user})")
      log_data("# FR: disable_reason #{e.data} from #{e.hook_name} (#{e.reason})")
      return e.data
    end

    # Function that tests if the targets blocks the move
    # @param user [PFM::PokemonBattler] user of the move
    # @param target [PFM::PokemonBattler] expected target
    # @note Thing that prevents the move from being used should be defined by :move_prevention_target Hook.
    # @return [Boolean] if the target evade the move (and is not selected)
    def move_blocked_by_target?(user, target)
      log_data("# move_blocked_by_target?(#{user}, #{target})")
      exec_hooks(Move, :move_prevention_target, binding) if user != target
      return false
    rescue Hooks::ForceReturn => e
      log_data("# FR: move_blocked_by_target? #{e.data} from #{e.hook_name} (#{e.reason})")
      return e.data
    end

    # Detect if the move is protected by another move on target
    # @param target [PFM::PokemonBattler]
    # @param symbol [Symbol]
    def blocked_by?(target, symbol)
      return blocable? && target.effects.has?(:protect) && target.last_successfull_move_is?(symbol)
    end

    class << self
      # Function that registers a move_prevention_user hook
      # @param reason [String] reason of the move_prevention_user registration
      # @yieldparam user [PFM::PokemonBattler]
      # @yieldparam targets [Array<PFM::PokemonBattler>]
      # @yieldparam move [Battle::Move]
      # @yieldreturn [:prevent, nil] :prevent if the move cannot continue
      def register_move_prevention_user_hook(reason)
        Hooks.register(Move, :move_prevention_user, reason) do |hook_binding|
          force_return(false) if yield(hook_binding.local_variable_get(:user), hook_binding.local_variable_get(:targets), self) == :prevent
        end
      end

      # Function that registers a move_disabled_check hook
      # @param reason [String] reason of the move_disabled_check registration
      # @yieldparam user [PFM::PokemonBattler]
      # @yieldparam move [Battle::Move]
      # @yieldreturn [Proc, nil] the code to execute if the move is disabled
      def register_move_disabled_check_hook(reason)
        Hooks.register(Move, :move_disabled_check, reason) do |hook_binding|
          result = yield(hook_binding.local_variable_get(:user), self)
          force_return(result) if result.respond_to?(:call)
        end
      end

      # Function that registers a move_prevention_target hook
      # @param reason [String] reason of the move_prevention_target registration
      # @yieldparam user [PFM::PokemonBattler]
      # @yieldparam target [PFM::PokemonBattler] expected target
      # @yieldparam move [Battle::Move]
      # @yieldreturn [Boolean] if the target is evading the move
      def register_move_prevention_target_hook(reason)
        Hooks.register(Move, :move_prevention_target, reason) do |hook_binding|
          force_return(true) if yield(hook_binding.local_variable_get(:user), hook_binding.local_variable_get(:target), self)
        end
      end
    end
  end

  # Effects
  Move.register_move_prevention_user_hook('PSDK Move prev user: Effects') do |user, targets, move|
    next move.logic.each_effects(user, *targets) do |effect|
      result = effect.on_move_prevention_user(user, targets, move)
      break result if result
    end
  end
  Move.register_move_prevention_target_hook('PSDK Move prev target: Effects') do |user, target, move|
    next move.logic.each_effects(user, target) do |effect|
      break true if effect.on_move_prevention_target(user, target, move) == true
    end == true
  end
  Move.register_move_disabled_check_hook('PSDK Move disable check: Effects') do |user, move|
    next move.logic.each_effects(user) do |effect|
      effect_proc = effect.on_move_disabled_check(user, move)
      break effect_proc if effect_proc.is_a?(Proc)
    end
  end

  # Prevent unimplemented moves from being used
  Move.register_move_disabled_check_hook('PSDK .24 moves disabled') do |_, move|
    next if move.class != Battle::Move

    next proc { move.scene.display_message_and_wait('\c[2]This move is not implemented!\c[0]') }
  end

  # Registers the magic bounce ability
  Hooks.register(Move, :effect_working, 'Magic Bounce Ability') do |move_binding|
    # @type [Battle::Move]
    move = self
    # @type [PFM::PokemonBattler]
    user = move_binding.local_variable_get(:user)
    # @type [Array<PFM::PokemonBattler>]
    actual_targets = move_binding.local_variable_get(:actual_targets)

    next unless move.magic_coat_affected?
    next unless user.can_be_lowered_or_canceled?(move.status? && actual_targets.any? { |target| target.has_ability?(:magic_bounce) })

    if move.affects_bank? # Send move back to user if affects the bank in order to apply the effect to the bank
      blocker = actual_targets.find { |target| target.has_ability?(:magic_bounce) }
      move.scene.visual.show_ability(blocker)
      actual_targets.clear << user
      next
    end

    # Send the moves back to the user if target has magic bounce
    actual_targets.map! do |target|
      next target unless target.has_ability?(:magic_bounce)

      move.scene.visual.show_ability(target)
      next user
    end
  end

  Hooks.register(Move, :effect_working, 'Magic Coat effect') do |move_binding|
    # @type [Battle::Move]
    move = self
    # @type [PFM::PokemonBattler]
    user = move_binding.local_variable_get(:user)
    # @type [Array<PFM::PokemonBattler>]
    actual_targets = move_binding.local_variable_get(:actual_targets)

    next unless move.magic_coat_affected?
    next unless user.can_be_lowered_or_canceled?(move.status? && actual_targets.any? { |target| target.effects.has?(:magic_coat) })

    if move.affects_bank? # Send move back to user if affects the bank in order to apply the effect to the bank
      actual_targets.clear << user
      next
    end

    # Send the moves back to the user if target has magic bounce
    actual_targets.map! { |target| target.effects.has?(:magic_coat) ? user : target }
  end
end
