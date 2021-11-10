module Battle
  module Effects
    class Ability
      class NaturalCure < Ability
        # Function called when a Pokemon has actually switched with another one
        # @param handler [Battle::Logic::SwitchHandler]
        # @param who [PFM::PokemonBattler] Pokemon that is switched out
        # @param with [PFM::PokemonBattler] Pokemon that is switched in
        def on_switch_event(handler, who, with)
          return if who != @target || who == with || who.status_effect.instance_of?(Status)

          who.cure
        end
      end
      register(:natural_cure, NaturalCure)
    end
  end
end
