module PFM
  class PokemonBattler
    # Check if the pokemon is grounded
    # @return [Boolean]
    def grounded?
      exec_hooks(PokemonBattler, :force_grounded, binding)
      exec_hooks(PokemonBattler, :force_flying, binding)
      return true
    rescue Hooks::ForceReturn => e
      log_data("# pokemon = #{self}")
      log_data("# FR: grounded? #{e.data} from #{e.hook_name} (#{e.reason})")
      return e.data
    end

    class << self
      # Register a hook forcing Pokemon to be grounded
      # @param reason [String] reason of the force_grounded hook
      # @yieldparam pokemon [PFM::PokemonBattler]
      # @yieldparam scene [Battle::Scene]
      # @yieldreturn [Boolean] if the Pokemon is forced to be grounded
      def register_force_grounded_hook(reason)
        Hooks.register(PokemonBattler, :force_grounded, reason) do
          force_return(true) if yield(self, @scene)
        end
      end

      # Register a hook forcing Pokemon to be flying (ie not grounded)
      # @param reason [String] reason of the force_flying hook
      # @yieldparam pokemon [PFM::PokemonBattler]
      # @yieldparam scene [Battle::Scene]
      # @yieldreturn [Boolean] if the Pokemon is forced to be "flying"
      def register_force_flying_hook(reason)
        Hooks.register(PokemonBattler, :force_flying, reason) do
          force_return(false) if yield(self, @scene)
        end
      end
    end

    register_force_grounded_hook('PSDK grounded: Gravity') { |_, scene| scene.logic.terrain_effects.has?(:gravity) }
    register_force_grounded_hook('PSDK grounded: Iron Ball') { |pokemon| pokemon.hold_item?(:iron_ball) }
    register_force_grounded_hook('PSDK grounded: Smack Down') { |pokemon| pokemon.effects.has?(:smack_down) }
    register_force_grounded_hook('PSDK grounded: Ingrain') { |pokemon| pokemon.effects.has?(:ingrain) }
    register_force_flying_hook('PSDK flying: Air Balloon') { |pokemon| pokemon.hold_item?(:air_balloon) }
    register_force_flying_hook('PSDK flying: Fly type') { |pokemon, _| pokemon.type_fly? }
    register_force_flying_hook('PSDK flying: Levitate') { |pokemon| pokemon.has_ability?(:levitate) }
  end
end
