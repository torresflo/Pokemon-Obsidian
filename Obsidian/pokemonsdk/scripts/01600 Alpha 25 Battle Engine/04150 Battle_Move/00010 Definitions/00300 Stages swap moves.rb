module Battle
  class Move
    # Class that manage Heart Swap move
    # @see https://bulbapedia.bulbagarden.net/wiki/Heart_Swap_(move)
    # @see https://pokemondb.net/move/heart-swap
    # @see https://www.pokepedia.fr/Permuc%C5%93ur
    class HeartSwap < StatAndStageEditBypassAccuracy
      private

      # Apply the stats or/and stage edition
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler]
      def edit_stages(user, target)
        target.acc_stage, user.acc_stage = user.acc_stage, target.acc_stage # Swap acc
        target.atk_stage, user.atk_stage = user.atk_stage, target.atk_stage # Swap atk
        target.ats_stage, user.ats_stage = user.ats_stage, target.ats_stage # Swap ats
        target.dfe_stage, user.dfe_stage = user.dfe_stage, target.dfe_stage # Swap dfe
        target.dfs_stage, user.dfs_stage = user.dfs_stage, target.dfs_stage # Swap dfs
        target.eva_stage, user.eva_stage = user.eva_stage, target.eva_stage # Swap eva
        target.spd_stage, user.spd_stage = user.spd_stage, target.spd_stage # Swap spd
        scene.display_message_and_wait(parse_text_with_pokemon(19, 673, user))
      end
    end
    Move.register(:s_heart_swap, HeartSwap)

    # Class that manage Power Swap move
    # @see https://bulbapedia.bulbagarden.net/wiki/Power_Swap_(move)
    # @see https://pokemondb.net/move/power-swap
    # @see https://www.pokepedia.fr/Permuforce
    class PowerSwap < StatAndStageEditBypassAccuracy
      private

      # Apply the stats or/and stage edition
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler]
      def edit_stages(user, target)
        target.atk_stage, user.atk_stage = user.atk_stage, target.atk_stage # Swap atk
        target.ats_stage, user.ats_stage = user.ats_stage, target.ats_stage # Swap ats
        scene.display_message_and_wait(parse_text_with_pokemon(19, 676, user))
      end
    end
    Move.register(:s_power_swap, PowerSwap)

    # Class that manage Guard Swap move
    # @see https://bulbapedia.bulbagarden.net/wiki/Guard_Swap_(move)
    # @see https://pokemondb.net/move/guard-swap
    # @see https://www.pokepedia.fr/Permugarde
    class GuardSwap < StatAndStageEditBypassAccuracy
      private
      
      # Apply the stats or/and stage edition
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler]
      def edit_stages(user, target)
        target.dfe_stage, user.dfe_stage = user.dfe_stage, target.dfe_stage # Swap dfe
        target.dfs_stage, user.dfs_stage = user.dfs_stage, target.dfs_stage # Swap dfs
        scene.display_message_and_wait(parse_text_with_pokemon(19, 679, user))
      end
    end
    Move.register(:s_guard_swap, GuardSwap)
  end
end