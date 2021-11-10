module Battle
  module Effects
    class Ability
      class Forewarn < Ability
        # Function called when a Pokemon has actually switched with another one
        # @param handler [Battle::Logic::SwitchHandler]
        # @param who [PFM::PokemonBattler] Pokemon that is switched out
        # @param with [PFM::PokemonBattler] Pokemon that is switched in
        def on_switch_event(handler, who, with)
          return if with != @target

          alive_foes = handler.logic.foes_of(with).select(&:alive?)
          return if alive_foes.empty?

          dangers = alive_foes.map do |foe|
            next [
              foe,
              foe.moveset.shuffle(random: handler.logic.generic_rng).max_by(&:power)
            ]
          end
          danger_foe, danger_move = dangers.shuffle(random: handler.logic.generic_rng).max_by { |(_, move)| move.power }
          return if danger_move.power <= 0

          handler.scene.visual.show_ability(with)
          handler.scene.display_message_and_wait(parse_text_with_pokemon(19, 433, danger_foe, PFM::Text::MOVE[1] => danger_move.name))
        end
      end
      register(:forewarn, Forewarn)
    end
  end
end
