module Battle
  module Effects
    class Item
      class ShedShell < Item
        # Function called when testing if pokemon can switch regardless of the prevension.
        # @param handler [Battle::Logic::SwitchHandler]
        # @param pokemon [PFM::PokemonBattler]
        # @param skill [Battle::Move, nil] potential skill used to switch
        # @param reason [Symbol] the reason why the SwitchHandler is called
        # @return [:passthrough, nil] if :passthrough, can_switch? will return true without checking switch_prevention
        def on_switch_passthrough(handler, pokemon, skill, reason)
          return if reason == :flee || pokemon != @target
          return if skill&.be_method == :s_teleport

          return :passthrough
        end
      end
      register(:shed_shell, ShedShell)
    end
  end
end
