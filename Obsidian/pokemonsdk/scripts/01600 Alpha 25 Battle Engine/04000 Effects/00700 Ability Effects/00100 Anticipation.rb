module Battle
  module Effects
    class Ability
      class Anticipation < Ability
        # Function called when a Pokemon has actually switched with another one
        # @param handler [Battle::Logic::SwitchHandler]
        # @param who [PFM::PokemonBattler] Pokemon that is switched out
        # @param with [PFM::PokemonBattler] Pokemon that is switched in
        def on_switch_event(handler, who, with)
          return if with != @target

          handler.logic.foes_of(with).each do |foe|
            next false if foe.dead?
            next false if foe.moveset.none? { |move| move.type_modifier(foe, with) >= 2 || move.be_method == :s_ohko }

            handler.scene.visual.show_ability(with)
            handler.scene.display_message_and_wait(parse_text_with_pokemon(19, 436, with))
          end
        end
      end
      register(:anticipation, Anticipation)
    end
  end
end
