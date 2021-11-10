module Battle
  class Logic
    class DamageHandler < ChangeHandlerBase
      include Hooks
      # Function telling if a damage can be applied and how much
      # @param hp [Integer] number of hp (damage) dealt
      # @param target [PFM::PokemonBattler]
      # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
      # @param skill [Battle::Move, nil] Potential move used
      # @note Thing that prevents the damage from being applied should be defined using :damage_prevention Hook.
      # @return [Integer, false]
      def damage_appliable(hp, target, launcher = nil, skill = nil)
        log_data("# damage_appliable(#{hp}, #{target}, #{launcher}, #{skill})")
        return false if target.hp <= 0

        reset_prevention_reason
        exec_hooks(DamageHandler, :damage_prevention, binding)
        return hp
      rescue Hooks::ForceReturn => e
        log_data("# FR: damage_appliable #{e.data} from #{e.hook_name} (#{e.reason})")
        return e.data
      end

      # Function that actually deal the damage
      # @param hp [Integer] number of hp (damage) dealt
      # @param target [PFM::PokemonBattler]
      # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
      # @param skill [Battle::Move, nil] Potential move used
      # @param messages [Proc] messages shown right before the post processing
      def damage_change(hp, target, launcher = nil, skill = nil, &messages)
        skill&.damage_dealt += hp
        @scene.visual.show_hp_animations([target], [-hp], [skill&.effectiveness], &messages)
        target.last_hit_by_move = skill if skill
        exec_hooks(DamageHandler, :post_damage, binding) if target.hp > 0
        exec_hooks(DamageHandler, :post_damage_death, binding) if target.hp <= 0
        target.add_damage_to_history(hp, launcher, skill, target.hp <= 0)
        log_data("# damage_change(#{hp}, #{target}, #{launcher}, #{skill}, #{target.hp <= 0})")
      rescue Hooks::ForceReturn => e
        log_data("# FR: damage_change #{e.data} from #{e.hook_name} (#{e.reason})")
        return e.data
      ensure
        @scene.visual.refresh_info_bar(target)
      end

      # Function that test if the damage can be dealt and deal the damage if so
      # @param hp [Integer] number of hp (damage) dealt
      # @param target [PFM::PokemonBattler]
      # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
      # @param skill [Battle::Move, nil] Potential move used
      # @param messages [Proc] messages shown right before the post processing
      def damage_change_with_process(hp, target, launcher = nil, skill = nil, &messages)
        return process_prevention_reason unless (hp = damage_appliable(hp, target, launcher, skill))

        process_prevention_reason # Ensure that things with damage change like substitute shows something
        damage_change(hp, target, launcher, skill, &messages)
      end

      # Function that proceed the heal of a Pokemon
      # @param target [PFM::PokemonBattler]
      # @param hp [Integer] number of HP to heal
      # @param test_heal_block [Boolean]
      # @param animation_id [Symbol, Integer] animation to use instead of the original one
      # @yieldparam hp [Integer] the actual hp healed
      # @return [Boolean] if the heal was successfull or not
      # @note this method yields a block in order to show the message after the animation
      # @note this shows the default message if no block has been given
      def heal(target, hp, test_heal_block: true, animation_id: nil)
        if test_heal_block && target.effects.has?(:heal_block)
          @scene.display_message_and_wait(parse_text_with_pokemon(19, 890, target))
          return false
        end
        if target.hp >= target.max_hp
          @scene.display_message_and_wait(parse_text_with_pokemon(19, 896, target))
          return false
        end

        actual_hp = hp.clamp(1, target.max_hp - target.hp)
        # TODO: play the animation that should be played on all hp heal (+think about animation_id)
        scene.visual.show_hp_animations([target], [actual_hp])
        if block_given?
          yield(actual_hp)
        else
          scene.display_message_and_wait(parse_text_with_pokemon(19, 387, target))
        end
        return true
      end

      # Function that drains a certain quantity of HP from the target and give it to the user
      # @param hp_factor [Integer] the division factor of HP to drain
      # @param target [PFM::PokemonBattler] target that get HP drained
      # @param launcher [PFM::PokemonBattler] launcher of a draining move/effect
      # @param skill [Battle::Move, nil] Potential move used
      # @param hp_overwrite [Integer, nil] for the number of hp drained by the move
      # @param drain_factor [Integer] the division factor of HP drained
      # @param messages [Proc] messages shown right before the post processing
      def drain(hp_factor, target, launcher, skill = nil, hp_overwrite: nil, drain_factor: 1, &messages)
        hp = hp_overwrite || (target.max_hp / hp_factor).clamp(0, Float::INFINITY)
        damage_change(hp, target, launcher, skill, &messages)
        # TODO: Add hooks for all those stuff
        if target.has_ability?(:liquid_ooze)
          @scene.visual.show_ability(target)
          damage_change(hp, launcher, launcher, nil)
          @scene.display_message_and_wait(parse_text_with_pokemon(19, 457, launcher))
        elsif launcher.effects.has?(:heal_block)
          @scene.display_message_and_wait(parse_text_with_pokemon(19, 890, launcher))
        elsif launcher.hp < launcher.max_hp
          hp = hp * 130 / 100 if launcher.hold_item?(:big_root)
          hp = hp * 3 / 2 if skill&.pulse? && launcher.has_ability?(:mega_launcher)
          @scene.visual.show_hp_animations([launcher], [(hp / drain_factor).clamp(1, Float::INFINITY)])
          @scene.display_message_and_wait(parse_text_with_pokemon(19, 905, target))
        end
      end

      # Function that test if the drain damages can be dealt and perform the drain if so
      # @param hp_factor [Integer] the division factor of HP to drain
      # @param target [PFM::PokemonBattler]
      # @param launcher [PFM::PokemonBattler] Potential launcher of a move
      # @param skill [Battle::Move, nil] Potential move used
      # @param hp_overwrite [Integer, nil] for the number of hp drained by the move
      # @param drain_factor [Integer] the division factor of HP drained
      # @param messages [Proc] messages shown right before the post processing
      def drain_with_process(hp_factor, target, launcher, skill = nil, hp_overwrite: nil, drain_factor: 1, &messages)
        hp = hp_overwrite || (target.max_hp / hp_factor).clamp(0, Float::INFINITY)
        return process_prevention_reason unless (hp = damage_appliable(hp, target, launcher, skill))

        drain(hp_factor, target, launcher, skill, hp_overwrite: hp, drain_factor: drain_factor, &messages)
      end

      class << self
        # Function that registers a damage_prevention hook
        # @param reason [String] reason of the damage_prevention registration
        # @yieldparam handler [DamageHandler]
        # @yieldparam hp [Integer] number of hp (damage) dealt
        # @yieldparam target [PFM::PokemonBattler]
        # @yieldparam launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @yieldparam skill [Battle::Move, nil] Potential move used
        # @yieldreturn [:prevent, Integer] :prevent if the damage cannot be applied, Integer if the hp variable should be updated
        def register_damage_prevention_hook(reason)
          Hooks.register(DamageHandler, :damage_prevention, reason) do |hook_binding|
            result = yield(
              self,
              hook_binding.local_variable_get(:hp),
              hook_binding.local_variable_get(:target),
              hook_binding.local_variable_get(:launcher),
              hook_binding.local_variable_get(:skill)
            )
            hook_binding.local_variable_set(:hp, result) if result.is_a?(Integer)
            force_return(false) if result == :prevent
          end
        end

        # Function that registers a post_damage hook (when target is still alive)
        # @param reason [String] reason of the post_damage registration
        # @yieldparam handler [DamageHandler]
        # @yieldparam hp [Integer] number of hp (damage) dealt
        # @yieldparam target [PFM::PokemonBattler]
        # @yieldparam launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @yieldparam skill [Battle::Move, nil] Potential move used
        def register_post_damage_hook(reason)
          Hooks.register(DamageHandler, :post_damage, reason) do |hook_binding|
            yield(
              self,
              hook_binding.local_variable_get(:hp),
              hook_binding.local_variable_get(:target),
              hook_binding.local_variable_get(:launcher),
              hook_binding.local_variable_get(:skill)
            )
          end
        end

        # Function that registers a post_damage_death hook (when target is KO)
        # @param reason [String] reason of the post_damage_death registration
        # @yieldparam handler [DamageHandler]
        # @yieldparam hp [Integer] number of hp (damage) dealt
        # @yieldparam target [PFM::PokemonBattler]
        # @yieldparam launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @yieldparam skill [Battle::Move, nil] Potential move used
        def register_post_damage_death_hook(reason)
          Hooks.register(DamageHandler, :post_damage_death, reason) do |hook_binding|
            yield(
              self,
              hook_binding.local_variable_get(:hp),
              hook_binding.local_variable_get(:target),
              hook_binding.local_variable_get(:launcher),
              hook_binding.local_variable_get(:skill)
            )
          end
        end
      end
    end

    # Effects
    DamageHandler.register_damage_prevention_hook('PSDK damage prev: Effects') do |handler, hp, target, launcher, skill|
      next handler.logic.each_effects(launcher, target) do |e|
        result = e.on_damage_prevention(handler, hp, target, launcher, skill)
        hp = result if result.is_a?(Integer)
        next result
      end || hp
    end
    DamageHandler.register_post_damage_hook('PSDK post damage: Effects') do |handler, hp, target, launcher, skill|
      handler.logic.each_effects(launcher, target) do |e|
        e.on_post_damage(handler, hp, target, launcher, skill)
      end
    end
    DamageHandler.register_post_damage_death_hook('PSDK post damage death: Effects') do |handler, hp, target, launcher, skill|
      handler.logic.each_effects(launcher, target) do |e|
        e.on_post_damage_death(handler, hp, target, launcher, skill)
      end
    end

    # Loyalty
    DamageHandler.register_post_damage_death_hook('PSDK post damage death: Loyalty update') do |_, _, target, launcher, _|
      next target.loyalty -= 1 unless launcher

      high_level_opponent = launcher.level - target.level >= 30
      low_loyalty = target.loyalty < 200
      if high_level_opponent
        target.loyalty -= low_loyalty ? 5 : 10
      else
        target.loyalty -= 1
      end
    end

    # Illusion
    DamageHandler.register_post_damage_hook('PSDK Post damage: Illusion') do |handler, _, target, launcher, skill|
      next unless skill && launcher != target
      next unless target.original.ability_db_symbol == :illusion && target.transform

      target.transform = nil
      handler.scene.visual.show_ability(target)
      handler.scene.visual.show_switch_form_animation(target)
      handler.scene.display_message_and_wait(parse_text_with_pokemon(19, 478, target))
    end
    DamageHandler.register_post_damage_death_hook('PSDK Post damage: Illusion') do |_, _, target, launcher, skill|
      next unless skill && launcher != target
      next unless target.original.ability_db_symbol == :illusion && target.transform

      target.transform = nil
    end
  end
end
