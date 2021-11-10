module Battle
  module Effects
    # Class that manage DestinyBond effect. Works together with Move::DestinyBond.
    # @see https://pokemondb.net/move/destiny-bond
    # @see https://bulbapedia.bulbagarden.net/wiki/Destiny_Bond_(move)
    # @see https://www.pokepedia.fr/Lien_du_Destin
    class DestinyBond < PokemonTiedEffectBase
      # Function called when we try to use a move as the user (returns :prevent if user fails)
      # @param user [PFM::PokemonBattler]
      # @param targets [Array<PFM::PokemonBattler>]
      # @param move [Battle::Move]
      # @return [:prevent, nil] :prevent if the move cannot continue
      def on_move_prevention_user(user, targets, move)
        return if dead? || user != @pokemon

        log_debug('PSDK Destiny Bond Effect: Effect removed with on_move_prevention_user.')
        kill
      end

      # Function called after damages were applied and when target died (post_damage_death)
      # @param handler [Battle::Logic::DamageHandler]
      # @param hp [Integer] number of hp (damage) dealt
      # @param target [PFM::PokemonBattler]
      # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
      # @param skill [Battle::Move, nil] Potential move used
      def on_post_damage_death(handler, hp, target, launcher, skill)
        return if @pokemon != target
        return unless skill && launcher != target && launcher
        return if handler.logic.allies_of(target).include?(launcher) # It says the opponent so an allie might kill the target

        handler.scene.display_message_and_wait(parse_text_with_pokemon(19, 629, target))
        handler.scene.visual.show_hp_animations([launcher], [-launcher.hp])
      end

      def name
        :destiny_bond
      end
    end
  end
end
