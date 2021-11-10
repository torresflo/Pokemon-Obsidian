module Battle
  class Move
    # Relic Song is a damage-dealing Normal-type move introduced in Generation V. It is the signature move of Meloetta.
    # @see https://pokemondb.net/move/relic-song
    # @see https://bulbapedia.bulbagarden.net/wiki/Relic_Song_(move)
    # @see https://www.pokepedia.fr/Chant_Antique
    class RelicSong < Basic
      private

      # Function that deals the damage to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_damage(user, actual_targets)
        super
        return unless user.db_symbol == :meloetta
        return unless user.form_calibrate(:dance)

        scene.visual.battler_sprite(user.bank, user.position).pokemon = user
        scene.display_message_and_wait(parse_text(22, 157, ::PFM::Text::PKNAME[0] => user.given_name))
      end
    end
    Move.register(:s_relic_song, RelicSong)
  end
end
