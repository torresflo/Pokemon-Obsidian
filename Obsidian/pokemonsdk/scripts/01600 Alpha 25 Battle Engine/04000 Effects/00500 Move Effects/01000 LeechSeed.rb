module Battle
  module Effects
    # Implementation of Leech Seed effect
    # This class drains the target hp to the Pokemon in the position of its user
    class LeechSeed < PositionTiedEffectBase
      include Mechanics::WithMarkedTargets

      # Create a new position LeechSeed effect
      # @param logic [Battle::Logic] logic used to get all the handler in order to allow the effect to work
      # @param user [PFM::PokemonBattler] receiver of that effect
      # @param target [PFM::PokemonBattler] pokemon getting the damages
      def initialize(logic, user, target)
        super(logic, user.bank, user.position)
        initialize_with_marked_targets(user, [target]) { |t| Mark.new(logic, t, self, leech_power) }
      end

      # Function that tells if the move is affected by Rapid Spin
      # @return [Boolean]
      def rapid_spin_affected?
        return true
      end

      # Divisor factor of the drain
      # @return [Integer]
      def leech_power
        8
      end

      # Get the name of the effect
      # @return [Symbol]
      def name
        :leech_seed
      end

      # Class marking the target of the LeechSeed so we cannot apply the effect twice
      class Mark < PokemonTiedEffectBase
        include Mechanics::Mark

        # Create a new mark
        # @param logic [Battle::Logic]
        # @param pokemon [PFM::PokemonBattler]
        # @param origin [LeechSeed] origin of the mark
        # @param leech_power [Integer] base power of the leech
        def initialize(logic, pokemon, origin, leech_power)
          super(logic, pokemon)
          initialize_mark(origin)
          @leech_power = leech_power
        end

        # Function that tells if the move is affected by Rapid Spin
        # @return [Boolean]
        def rapid_spin_affected?
          return true
        end

        # Get the name of the effect
        # @return [Symbol]
        def name
          :leech_seed_mark
        end

        # Function called at the end of a turn
        # @param logic [Battle::Logic] logic of the battle
        # @param scene [Battle::Scene] battle scene
        # @param battlers [Array<PFM::PokemonBattler>] all alive battlers
        def on_end_turn_event(logic, scene, battlers)
          return if dead?

          origin = LeechSeed.from(mark_origin)
          launcher = origin.launcher
          pkmn = logic.alive_battlers(launcher.bank).include?(launcher) ? launcher : logic.battler(origin.bank, origin.position)
          return if pkmn.nil? || pkmn.dead? || @pokemon.dead?
          return if @pokemon.has_ability?(:magic_guard)

          scene.display_message_and_wait(parse_text_with_pokemon(19, 610, @pokemon))
          # TODO: Add an animation
          logic.damage_handler.drain(@leech_power, @pokemon, pkmn)
        end

        # Transfer the effect to the given pokemon via baton switch
        # @param with [PFM::Battler] the pokemon switched in
        # @return [Battle::Effects::PokemonTiedEffectBase, nil] the effect to give to the switched in pokemon, nil if there is this effect isn't transferable via baton pass
        def baton_switch_transfer(with)
          return Mark.new(@logic, with, @mark_origin, @leech_power)
        end
      end
    end
  end
end
