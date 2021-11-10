module Battle
  class Move
    # Class that manage the Power Split move
    # @see https://bulbapedia.bulbagarden.net/wiki/Power_Split_(move)
    # @see https://pokemondb.net/move/power-split
    # @see https://www.pokepedia.fr/Partage_Force
    class PowerSplit < StatAndStageEditBypassAccuracy
      private

      # Apply the stats or/and stage edition
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler]
      def edit_stages(user, target)
        user.atk_basis = target.atk_basis = ((user.atk_basis + target.atk_basis) / 2).floor # Share atk
        user.ats_basis = target.ats_basis = ((user.ats_basis + target.ats_basis) / 2).floor # Share ats
        scene.display_message_and_wait(parse_text_with_pokemon(19, 1102, user))
      end
    end
    Move.register(:s_power_split, PowerSplit)
  
    # Class that manage the Guard Split move
    # @see https://bulbapedia.bulbagarden.net/wiki/Guard_Split_(move)
    # @see https://pokemondb.net/move/guard-split
    # @see https://www.pokepedia.fr/Partage_Garde
    class GuardSplit < StatAndStageEditBypassAccuracy
      private

      # Apply the stats or/and stage edition
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler]
      def edit_stages(user, target)
        user.dfe_basis = target.dfe_basis = ((user.dfe_basis + target.dfe_basis) / 2).floor # Share dfe
        user.dfs_basis = target.dfs_basis = ((user.dfs_basis + target.dfs_basis) / 2).floor # Share dfs
        scene.display_message_and_wait(parse_text_with_pokemon(19, 1105, user))
      end
    end
    Move.register(:s_guard_split, GuardSplit)
  end
end