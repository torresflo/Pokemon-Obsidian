module Battle
  module Effects
    class Ability
      class ShadowTag < Ability
        # Function called when testing if pokemon can switch (when he couldn't passthrough)
        # @param handler [Battle::Logic::SwitchHandler]
        # @param pokemon [PFM::PokemonBattler]
        # @param skill [Battle::Move, nil] potential skill used to switch
        # @param reason [Symbol] the reason why the SwitchHandler is called
        # @return [:prevent, nil] if :prevent, can_switch? will return false
        def on_switch_prevention(handler, pokemon, skill, reason)
          return if effect_prevented?(pokemon, skill)

          return handler.prevent_change do
            handler.scene.visual.show_ability(@target)
            text = parse_text_with_pokemon(19, 881, @target, PFM::Text::PKNICK[0] => @target.given_name,
                                                             PFM::Text::ABILITY[1] => @target.ability_name)
            handler.scene.display_message_and_wait(text)
          end
        end

        private

        # Additional check that prevent effect
        # @param pokemon [PFM::PokemonBattler]
        # @param skill [Battle::Move, nil] potential skill used to switch
        # @return [Boolean]
        def effect_prevented?(pokemon, skill)
          return pokemon.bank == @target.bank || pokemon.type_ghost?
        end
      end
      register(:shadow_tag, ShadowTag)

      class MagnetPull < ShadowTag
        private

        # Additional check that prevent effect
        # @param pokemon [PFM::PokemonBattler]
        # @param skill [Battle::Move, nil] potential skill used to switch
        # @return [Boolean]
        def effect_prevented?(pokemon, skill)
          return pokemon.bank == @target.bank || !pokemon.type_steel?
        end
      end
      register(:magnet_pull, MagnetPull)

      class SuctionCups < ShadowTag
        private

        # Additional check that prevent effect
        # @param pokemon [PFM::PokemonBattler]
        # @param skill [Battle::Move, nil] potential skill used to switch
        # @return [Boolean]
        # @note I think this ability is not designed to be implemented like this, it should kill the passthrough
        # @todo fix this ability
        def effect_prevented?(pokemon, skill)
          return pokemon.bank == @target.bank || !skill || skill.force_switch?
        end
      end
      register(:suction_cups, SuctionCups)

      class ArenaTrap < ShadowTag
        private

        # Additional check that prevent effect
        # @param pokemon [PFM::PokemonBattler]
        # @param skill [Battle::Move, nil] potential skill used to switch
        # @return [Boolean]
        def effect_prevented?(pokemon, skill)
          return pokemon.bank == @target.bank || !pokemon.grounded?
        end
      end
      register(:arena_trap, ArenaTrap)
    end
  end
end
