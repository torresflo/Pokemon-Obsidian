module Battle
  class Move
    # User's own Attack and Defense switch.
    # @see https://pokemondb.net/move/power-trick
    # @see https://bulbapedia.bulbagarden.net/wiki/Power_Trick_(move)
    # @see https://www.pokepedia.fr/Astuce_Force
    class PowerTrick < StatAndStageEdit
      private

      # Apply the exchange
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler]
      def edit_stages(user, target)
        old_atk, old_dfe = target.atk_basis, target.dfe_basis
        target.atk_basis, target.dfe_basis = target.dfe_basis, target.atk_basis
        scene.display_message_and_wait(parse_text_with_pokemon(19, 773, target))
        log_data("power trick # #{target.name} exchange atk and dfe (atk:#{old_atk} > #{target.atk_basis}) (dfe:#{old_dfe} > #{target.dfe_basis})")
      end
    end
    Move.register(:s_power_trick, PowerTrick)
  end
end