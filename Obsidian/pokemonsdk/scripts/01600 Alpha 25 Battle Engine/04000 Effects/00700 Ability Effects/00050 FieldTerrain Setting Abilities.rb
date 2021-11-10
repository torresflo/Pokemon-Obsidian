module Battle
  module Effects
    class Ability
      class ElectricSurge < Ability
        # Function called when a Pokemon has actually switched with another one
        # @param handler [Battle::Logic::SwitchHandler]
        # @param who [PFM::PokemonBattler] Pokemon that is switched out
        # @param with [PFM::PokemonBattler] Pokemon that is switched in
        def on_switch_event(handler, who, with)
          return if with != @target

          fterrain_handler = handler.logic.fterrain_change_handler
          return unless fterrain_handler.fterrain_appliable?(terrain_type)

          handler.scene.visual.show_ability(with)
          fterrain_handler.fterrain_change(terrain_type)
        end

        private

        # Tell which fieldterrain will be set
        # @return [Symbol]
        def terrain_type
          return :electric_terrain
        end
      end
      register(:electric_surge, ElectricSurge)

      class GrassySurge < ElectricSurge
        private

        # Tell which fieldterrain will be set
        # @return [Symbol]
        def terrain_type
          return :grassy_terrain
        end
      end
      register(:grassy_surge, GrassySurge)

      class MistySurge < ElectricSurge
        private

        # Tell which fieldterrain will be set
        # @return [Symbol]
        def terrain_type
          return :misty_terrain
        end
      end
      register(:misty_surge, MistySurge)

      class PsychicSurge < ElectricSurge
        private

        # Tell which fieldterrain will be set
        # @return [Symbol]
        def terrain_type
          return :psychic_terrain
        end
      end
      register(:psychic_surge, PsychicSurge)
    end
  end
end
