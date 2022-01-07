module Battle
  module Effects
    class Ability
      class Regenerator < Ability
        # Function called when a Pokemon has actually switched with another one
        # @param handler [Battle::Logic::SwitchHandler]
        # @param who [PFM::PokemonBattler] Pokemon that is switched out
        # @param with [PFM::PokemonBattler] Pokemon that is switched in
        def on_switch_event(handler, who, with)
          return if who != @target || who == with || who.hp == who.max_hp || who.dead?

          who.hp += who.max_hp / 3
        end
      end
      register(:regenerator, Regenerator)
    end
  end
end
