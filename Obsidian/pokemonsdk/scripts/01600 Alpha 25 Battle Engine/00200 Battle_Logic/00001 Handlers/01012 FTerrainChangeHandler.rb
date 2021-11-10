module Battle
  class Logic
    # Handler responsive of answering properly terrain changes requests
    class FTerrainChangeHandler < ChangeHandlerBase
      include Hooks
      # Weather thingies copiepasted, I don't think this is really useful right now
      FTERRAIN_SYM_TO_MSG = {
        none: {
          electric_terrain: 227,
          grassy_terrain: 223,
          misty_terrain: 225,
          psychic_terrain: 347
        },
        electric_terrain: 226,
        grassy_terrain: 222,
        misty_terrain: 224,
        psychic_terrain: 346
      }

      # Function telling if a terrain can be applyied
      # @param fterrain_type [Symbol] :none, :electric_terrain, :grassy_terrain, :misty_terrain, :psychic_terrain
      # @return [Boolean]
      def fterrain_appliable?(fterrain_type)
        log_data("# fterrain_appliable?(#{fterrain_type})")
        reset_prevention_reason
        last_fterrain = @logic.field_terrain || :none
        exec_hooks(FTerrainChangeHandler, :fterrain_prevention, binding)
        return true
      rescue Hooks::ForceReturn => e
        log_data("# FR: fterrain_appliable? #{e.data} from #{e.hook_name} (#{e.reason})")
        return e.data
      end

      # Function that actually change the terrain
      # @param fterrain_type [Symbol] :none, :electric_terrain, :grassy_terrain, :misty_terrain, :psychic_terrain
      def fterrain_change(fterrain_type)
        log_data("# fterrain_change(#{fterrain_type})")
        last_fterrain = @logic.field_terrain || :none
        @logic.field_terrain = fterrain_type
        @logic.field_terrain_effect # <= This will force the field terrain effect to be initialized to the right value
        show_fterrain_message(last_fterrain, fterrain_type)
        exec_hooks(FTerrainChangeHandler, :post_fterrain_change, binding)
      rescue Hooks::ForceReturn => e
        log_data("# FR: fterrain_change #{e.data} from #{e.hook_name} (#{e.reason})")
        return e.data
      end

      # Function that test if the change is possible and perform the change if so
      # @param fterrain_type [Symbol] :none, :electric_terrain, :grassy_terrain, :misty_terrain, :psychic_terrain
      def fterrain_change_with_process(fterrain_type)
        return process_prevention_reason unless fterrain_appliable?(fterrain_type)

        fterrain_change(fterrain_type)
      end

      private

      # Show the terrain  message
      # @param last_fterrain [Symbol]
      # @param current_fterrain [Symbol]
      def show_fterrain_message(last_fterrain, current_fterrain)
        return if last_fterrain == current_fterrain

        if current_fterrain == :none
          @scene.display_message_and_wait(parse_text(60, FTERRAIN_SYM_TO_MSG[current_fterrain][last_fterrain]))
        else
          @scene.display_message_and_wait(parse_text(60, FTERRAIN_SYM_TO_MSG[:none][last_fterrain])) if last_fterrain != :none
          @scene.display_message_and_wait(parse_text(60, FTERRAIN_SYM_TO_MSG[current_fterrain]))
        end
      end

      class << self
        # Function that registers a fterrain_prevetion hook
        # @param reason [String] reason of the fterrain_prevetion registration
        # @yieldparam handler [FTerrainChangeHandler]
        # @yieldparam fterrain_type [Symbol] :none, :electric_terrain, :grassy_terrain, :misty_terrain, :psychic_terrain
        # @yieldparam last_fterrain [Symbol] :none, :electric_terrain, :grassy_terrain, :misty_terrain, :psychic_terrain
        # @yieldreturn [:prevent, nil] :prevent if the status cannot be applied
        def register_fterrain_prevention_hook(reason)
          Hooks.register(FTerrainChangeHandler, :fterrain_prevention, reason) do |hook_binding|
            result = yield(
              self,
              hook_binding.local_variable_get(:fterrain_type),
              hook_binding.local_variable_get(:last_fterrain)
            )
            force_return(false) if result == :prevent
          end
        end

        # Function that registers a post_fterrain_handler hook
        # @param reason [String] reason of the post_fterrain_handler registration
        # @yieldparam handler [FTerrainChangeHandler]
        # @yieldparam fterrain_type [Symbol] :none, :electric_terrain, :grassy_terrain, :misty_terrain, :psychic_terrain
        # @yieldparam last_fterrain [Symbol] :none, :electric_terrain, :grassy_terrain, :misty_terrain, :psychic_terrain
        def register_post_fterrain_change_hook(reason)
          Hooks.register(FTerrainChangeHandler, :post_fterrain_change, reason) do |hook_binding|
            yield(
              self,
              hook_binding.local_variable_get(:fterrain_type),
              hook_binding.local_variable_get(:last_fterrain)
            )
          end
        end
      end
    end

    FTerrainChangeHandler.register_fterrain_prevention_hook('PSDK prev field terrain: Effects') do |handler, fterrain_type, last_fterrain|
      next handler.logic.each_effects(*handler.logic.all_alive_battlers) do |e|
        next e.on_fterrain_prevention(handler, fterrain_type, last_fterrain)
      end
    end
    FTerrainChangeHandler.register_post_fterrain_change_hook('PSDK post field terrain: Effects') do |handler, fterrain_type, last_fterrain|
      next handler.logic.each_effects(*handler.logic.all_alive_battlers) do |e|
        next e.on_post_fterrain_change(handler, fterrain_type, last_fterrain)
      end
    end

    FTerrainChangeHandler.register_fterrain_prevention_hook('PSDK prev field terrain: Duplicate field terrain') do |_, fterrain, prev|
      next if fterrain != prev

      next :prevent
    end
  end
end
