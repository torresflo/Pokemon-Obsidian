module Battle
  module Effects
    # Lunar Dance Effect
    class LunarDance < PokemonTiedEffectBase
      # Get the name of the effect
      # @return [Symbol]
      def name
        return :lunar_dance
      end

      # Function called when a Pokemon has actually switched with another one
      # @param handler [Battle::Logic::SwitchHandler]
      # @param who [PFM::PokemonBattler] Pokemon that is switched out
      # @param with [PFM::PokemonBattler] Pokemon that is switched in
      def on_switch_event(handler, who, with)
        handler.scene.display_message_and_wait(parse_text_with_pokemon(19, 694, with))
        handler.scene.visual.show_hp_animations([with], [with.max_hp])
        handler.logic.status_change_handler.status_change_with_process(:cure, with)
        with.skills_set.each { |skill| skill.pp = skill.ppmax }
      end
    end
  end
end
