module Battle
  class Logic
    # Handler responsive of answering properly status changes requests
    class StatusChangeHandler < ChangeHandlerBase
      include Hooks
      # List of method to call in order to apply the status on the Pokemon
      STATUS_APPLY_METHODS = {
        poison: :status_poison,
        toxic: :status_toxic,
        confusion: :status_confuse,
        sleep: :status_sleep,
        freeze: :status_frozen,
        paralysis: :status_paralyze,
        burn: :status_burn,
        cure: :cure,
        flinch: :apply_flinch
      }
      # List of correspondance between Status ID and Symbol
      STATUS_ID_TO_SYMBOL = { 
        GameData::States::POISONED => :poison,
        GameData::States::PARALYZED => :paralysis,
        GameData::States::BURN => :burn,
        GameData::States::ASLEEP => :sleep,
        GameData::States::FROZEN => :freeze, 
        GameData::States::CONFUSED => :confusion,
        GameData::States::TOXIC => :toxic,
        GameData::States::FLINCH => :flinch 
      }
      # List of message ID when applying a status
      STATUS_APPLY_MESSAGE = { poison: 234, toxic: 237, confusion: 345, sleep: 306, freeze: 288, paralysis: 273, burn: 255 }
      # List of animation ID when applying a status
      STATUS_APPLY_ANIMATION = { poison: 470, toxic: 477, confusion: 475, sleep: 473, freeze: 474, paralysis: 471, burn: 472, flinch: 476 }

      # Function telling if a status can be applyied
      # @param status [Symbol] :poison, :toxic, :confusion, :sleep, :freeze, :paralysis, :burn, :flinch
      # @param target [PFM::PokemonBattler]
      # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
      # @param skill [Battle::Move, nil] Potential move used
      # @note Thing that prevents the status from being applyied should be defined using :status_prevention Hook.
      # @return [Boolean]
      def status_appliable?(status, target, launcher = nil, skill = nil)
        return false if target.hp <= 0

        reset_prevention_reason
        exec_hooks(StatusChangeHandler, :status_prevention, binding) if status != :cure
        return true
      rescue Hooks::ForceReturn => e
        log_data("# status = #{status}; target = #{target}; launcher = #{launcher}; skill = #{skill}")
        log_data("# FR: status_appliable? #{e.data} from #{e.hook_name} (#{e.reason})")
        return e.data
      end

      # Function that actually change the status
      # @param status [Symbol] :poison, :toxic, :confusion, :sleep, :freeze, :paralysis, :burn, :flinch, :cure, :confuse_cure
      # @param target [PFM::PokemonBattler]
      # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
      # @param skill [Battle::Move, nil] Potential move used
      # @param message_overwrite [Integer] Index of the message to use if file 19 to apply the status (if there's specific reason)
      def status_change(status, target, launcher = nil, skill = nil, message_overwrite: nil)
        log_data("# status_change(#{status}, #{target}, #{launcher}, #{skill})")
        if status == :cure
          message_overwrite ||= cure_message_id(target)
          target.send(STATUS_APPLY_METHODS[status])
        elsif status == :confuse_cure
          target.effects.get(:confusion)&.kill
          target.effects.delete_specific_dead_effect(:confusion)
        else
          message_overwrite ||= STATUS_APPLY_MESSAGE[status]
          target.send(STATUS_APPLY_METHODS[status], true)
          @scene.visual.show_rmxp_animation(target, STATUS_APPLY_ANIMATION[status])
        end
        @scene.display_message_and_wait(parse_text_with_pokemon(19, message_overwrite, target)) if message_overwrite
        exec_hooks(StatusChangeHandler, :post_status_change, binding)
      rescue Hooks::ForceReturn => e
        log_data("# FR: status_change #{e.data} from #{e.hook_name} (#{e.reason})")
        return e.data
      ensure
        @scene.visual.refresh_info_bar(target)
      end

      # Function that test if the change is possible and perform the change if so
      # @param status [Symbol] :poison, :toxic, :confusion, :sleep, :freeze, :paralysis, :burn, :flinch, :cure
      # @param target [PFM::PokemonBattler]
      # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
      # @param skill [Battle::Move, nil] Potential move used
      def status_change_with_process(status, target, launcher = nil, skill = nil, message_overwrite: nil)
        return process_prevention_reason unless status_appliable?(status, target, launcher, skill)

        status_change(status, target, launcher, skill, message_overwrite: message_overwrite)
      end

      private

      # Get the message ID for the curing message
      # @param target [PFM::PokemonBattler]
      # @return [Integer]
      def cure_message_id(target)
        if target.poisoned? || target.toxic?
          return 246
        elsif target.burn?
          return 264
        elsif target.frozen?
          return 294
        elsif target.paralyzed?
          return 279
        else # asleep
          return 312
        end
      end

      class << self
        # Function that registers a status_prevention hook
        # @param reason [String] reason of the status_prevention registration
        # @yieldparam handler [StatusChangeHandler]
        # @yieldparam status [Symbol] :poison, :toxic, :confusion, :sleep, :freeze, :paralysis, :burn, :flinch, :cure
        # @yieldparam target [PFM::PokemonBattler]
        # @yieldparam launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @yieldparam skill [Battle::Move, nil] Potential move used
        # @yieldreturn [:prevent, nil] :prevent if the status cannot be applied
        def register_status_prevention_hook(reason)
          Hooks.register(StatusChangeHandler, :status_prevention, reason) do |hook_binding|
            result = yield(
              self,
              hook_binding.local_variable_get(:status),
              hook_binding.local_variable_get(:target),
              hook_binding.local_variable_get(:launcher),
              hook_binding.local_variable_get(:skill)
            )
            force_return(false) if result == :prevent
          end
        end

        # Function that registers a post_status_change hook
        # @param reason [String] reason of the post_status_change registration
        # @yieldparam handler [StatusChangeHandler]
        # @yieldparam status [Symbol] :poison, :toxic, :confusion, :sleep, :freeze, :paralysis, :burn, :flinch, :cure
        # @yieldparam target [PFM::PokemonBattler]
        # @yieldparam launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @yieldparam skill [Battle::Move, nil] Potential move used
        def register_post_status_change_hook(reason)
          Hooks.register(StatusChangeHandler, :post_status_change, reason) do |hook_binding|
            yield(
              self,
              hook_binding.local_variable_get(:status),
              hook_binding.local_variable_get(:target),
              hook_binding.local_variable_get(:launcher),
              hook_binding.local_variable_get(:skill)
            )
          end
        end
      end
    end

    # Effects
    StatusChangeHandler.register_post_status_change_hook('PSDK post status: Effects') do |handler, status, target, launcher, skill|
      handler.logic.each_effects(target, launcher) do |effect|
        next effect.on_post_status_change(handler, status, target, launcher, skill)
      end
    end
    StatusChangeHandler.register_status_prevention_hook('PSDK status prev: Effects') do |handler, status, target, launcher, skill|
      next handler.logic.each_effects(target, launcher) do |effect|
        next effect.on_status_prevention(handler, status, target, launcher, skill)
      end
    end

    # Shaymin form
    StatusChangeHandler.register_post_status_change_hook('Shaymin form') do |handler, _, target, _, _|
      next unless target.db_symbol == :shaymin && target.frozen?
      next unless target.form_calibrate(:none)

      handler.scene.visual.battler_sprite(target.bank, target.position).pokemon = target
      handler.scene.display_message_and_wait(parse_text(22, 157, ::PFM::Text::PKNAME[0] => target.given_name))
    end

    # Already confused
    StatusChangeHandler.register_status_prevention_hook('PSDK status prev: confused') do |handler, status, target|
      next if status != :confusion || !target.confused?

      next handler.prevent_change do
        handler.scene.display_message_and_wait(parse_text_with_pokemon(19, 354, target))
      end
    end

    # Cannot fall asleep
    StatusChangeHandler.register_status_prevention_hook('PSDK status prev: can_be_asleep') do |handler, status, target, _, skill|
      next if status != :sleep || target.can_be_asleep? || skill&.db_symbol == :rest

      next handler.prevent_change do
        handler.scene.display_message_and_wait(parse_text_with_pokemon(19, 318, target))
      end
    end

    # Cannot be frozen
    StatusChangeHandler.register_status_prevention_hook('PSDK status prev: can_be_frozen') do |handler, status, target, _, skill|
      next if status != :freeze || target.can_be_frozen?(skill&.type || 0)

      next handler.prevent_change do
        handler.scene.display_message_and_wait(parse_text_with_pokemon(19, 300, target)) if skill.nil? || skill.status?
      end
    end

    # Cannot be poisoned
    StatusChangeHandler.register_status_prevention_hook('PSDK status prev: can_be_poisoned') do |handler, status, target, _, skill|
      next if status != :poison && status != :toxic || target.can_be_poisoned?

      next handler.prevent_change do
        handler.scene.display_message_and_wait(parse_text_with_pokemon(19, 252, target)) if skill.nil? || skill.status?
      end
    end

    # Cannot be paralyzed
    StatusChangeHandler.register_status_prevention_hook('PSDK status prev: can_be_paralyzed') do |handler, status, target, _, skill|
      next if status != :paralysis || target.can_be_paralyzed? || skill&.db_symbol == :body_slam

      next handler.prevent_change do
        handler.scene.display_message_and_wait(parse_text_with_pokemon(19, 285, target)) if skill.nil? || skill.status?
      end
    end

    # Cannot be burn
    StatusChangeHandler.register_status_prevention_hook('PSDK status prev: can_be_burn') do |handler, status, target, _, skill|
      next if status != :burn || target.can_be_burn?

      next handler.prevent_change do
        handler.scene.display_message_and_wait(parse_text_with_pokemon(19, 270, target)) if skill.nil? || skill.status?
      end
    end
  end
end
