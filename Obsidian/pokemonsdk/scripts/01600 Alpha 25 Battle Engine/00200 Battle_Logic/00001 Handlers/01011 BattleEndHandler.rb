module Battle
  class Logic
    # Handler responsive of handling the end of the battle
    class BattleEndHandler < ChangeHandlerBase
      include Hooks

      # Process the battle end
      def process
        @scene.message_window.blocking = true
        players_pokemon = @logic.all_battlers.select(&:from_party?)
        exec_hooks(BattleEndHandler, :battle_end, binding)
        exec_hooks(BattleEndHandler, :battle_end_no_defeat, binding) if @logic.battle_result != 2
        @logic.all_battlers(&:copy_properties_back_to_original)
        exec_hooks(BattleEndHandler, :battle_end_nuzlocke, binding) if PFM.game_state.nuzlocke.enabled?
        unless $scene.is_a?(Yuki::SoftReset) || $scene.is_a?(Scene_Title)
          $game_system.bgm_play($game_system.playing_bgm)
          $game_system.bgs_play($game_system.playing_bgs)
        end
      end

      # Get the item to pick up
      # @param pokemon [PFM::Pokemon]
      # @return [Integer]
      def pickup_item(pokemon)
        off = (((pokemon.level - 1.0) / GameData::MAX_LEVEL) * 10).to_i # Offset should always depends on the final max level
        ind = pickup_index(@logic.generic_rng.rand(100))
        env = $env
        return GameData::GrassItem[off][ind] if env.tall_grass? || env.grass?
        return GameData::CaveItem[off][ind] if env.cave? || env.mount?
        return GameData::WaterItem[off][ind] if env.sea? || env.pond?

        return GameData::CommonItem[off][ind]
      end

      # Process the loose sequence when the battle doesn't allow defeat
      def player_loose_sequence
        lost_money = calculate_lost_money
        variables = { PFM::Text::TRNAME[0] => $trainer.name, PFM::Text::NUMXR => lost_money.to_s }
        @scene.message_window.stay_visible = true
        @scene.visual.lock do
          @scene.display_message(parse_text(18, 56, variables))
          @scene.display_message(parse_text(18, @scene.battle_info.trainer_battle? ? 58 : 57, variables))
          @scene.display_message(parse_text(18, 59, variables))
        end
      end

      private

      # Get the right pickup index
      # @param seed [Integer]
      # @return [Integer]
      def pickup_index(seed)
        return 0 if seed < 30
        return (1 + (seed - 30) / 10) if seed < 80
        return 6 if seed < 88
        return 7 if seed < 94
        return 8 if seed < 99

        return 9
      end

      # Get the money the player looses when he lose a battle
      # @return [Integer]
      def calculate_lost_money
        base_payout * @logic.battler(0, 0).level
      end

      # Get the base payout to calculate the lost money
      # @return [Integer]
      def base_payout
        return [8, 16, 24, 36, 48, 64, 80, 100, 120][$trainer.badge_counter] || 120
      end

      class << self
        # Function that registers a battle end procedure
        # @param reason [String] reason of the battle_end registration
        # @yieldparam handler [BattleEndHandler]
        # @yieldparam players_pokemon [Array<PFM::PokemonBattler>]
        def register(reason)
          Hooks.register(BattleEndHandler, :battle_end, reason) do |hook_binding|
            yield(self, hook_binding.local_variable_get(:players_pokemon))
          end
        end

        # Function that registers a battle end procedure when it's not a defeat
        # @param reason [String] reason of the battle_end_no_defeat registration
        # @yieldparam handler [BattleEndHandler]
        # @yieldparam players_pokemon [Array<PFM::PokemonBattler>]
        def register_no_defeat(reason)
          Hooks.register(BattleEndHandler, :battle_end_no_defeat, reason) do |hook_binding|
            yield(self, hook_binding.local_variable_get(:players_pokemon))
          end
        end

        # Function that registers a battle end procedure when nuzlocke mode is enabled
        # @param reason [String] reason of the battle_end_nuzlocke registration
        # @yieldparam handler [BattleEndHandler]
        # @yieldparam players_pokemon [Array<PFM::PokemonBattler>]
        def register_nuzlocke(reason)
          Hooks.register(BattleEndHandler, :battle_end_nuzlocke, reason) do |hook_binding|
            yield(self, hook_binding.local_variable_get(:players_pokemon))
          end
        end
      end
    end

    BattleEndHandler.register('PSDK set switches') do |handler|
      $game_switches[Yuki::Sw::BT_Catch] = !handler.logic.battle_info.caught_pokemon.nil?
      $game_switches[Yuki::Sw::BT_Defeat] = handler.logic.battle_result == 2
      $game_switches[Yuki::Sw::BT_Victory] = handler.logic.battle_result == 0
      $game_switches[Yuki::Sw::BT_NoEscape] = false
    end

    BattleEndHandler.register('PSDK reset weather to normal') do
      $env.apply_weather(:none, 0) unless $game_switches[Yuki::Sw::MixWeather]
    end

    BattleEndHandler.register('PSDK trainer messages') do |handler|
      next unless $game_temp.trainer_battle

      # Showing trainers
      $game_temp.vs_type.times.map do |i|
        next handler.scene.visual.battler_sprite(1, -i - 1)
      end.compact.each(&:go_in)
      ids = [$game_variables[Yuki::Var::Trainer_Battle_ID], $game_variables[Yuki::Var::Second_Trainer_ID]].select { |i| i > 0 }
      if handler.logic.battle_result == 0
        handler.logic.battle_phase_exp
        Audio.bgm_play(*handler.scene.battle_info.victory_bgm)
        # Defeat message
        ids.each do |id|
          handler.scene.display_message_and_wait(text_get(48, id))
        end
        # Add money
        if (v = handler.scene.battle_info.total_money(handler.logic)) > 0
          PFM.game_state.add_money(v)
          handler.scene.display_message_and_wait(parse_text(18, 60, PFM::Text::TRNAME[0] => $trainer.name, PFM::Text::NUMXR => v.to_s))
        end
      else
        # Victory message
        ids.each do |id|
          handler.scene.display_message_and_wait(text_get(47, id))
        end
      end
    end

    BattleEndHandler.register('PSDK wild victory') do |handler|
      next if $game_temp.trainer_battle || handler.logic.battle_result.between?(1, 2)

      Audio.bgm_play(*handler.scene.battle_info.victory_bgm)
      handler.logic.battle_phase_exp
      if (v = handler.scene.battle_info.additional_money) > 0
        PFM.game_state.add_money(v)
        handler.scene.display_message_and_wait(parse_text(18, 61, PFM::Text::TRNAME[0] => $trainer.name, PFM::Text::NUMXR => v.to_s))
      end
    end

    BattleEndHandler.register_no_defeat('PSDK natural cure') do |_, players_pokemon|
      players_pokemon.each do |pokemon|
        pokemon.cure if pokemon.original.ability_db_symbol == :natural_cure
      end
    end

    BattleEndHandler.register_no_defeat('PSDK honey gather') do |handler, players_pokemon|
      players_pokemon.each do |pokemon|
        next unless pokemon.original.ability_db_symbol == :honey_gather && pokemon.item_holding == 0 && handler.logic.generic_rng.rand(100) < (pokemon.level / 2)
        next if pokemon.original.egg?

        pokemon.item_holding = GameData::Item[:honey].id
      end
    end

    BattleEndHandler.register_no_defeat('PSDK pickup') do |handler, players_pokemon|
      players_pokemon.each do |pokemon|
        next unless pokemon.original.ability_db_symbol == :pickup && pokemon.item_holding == 0 && handler.logic.generic_rng.rand(100) < 10
        next if pokemon.original.egg?

        pokemon.item_holding = handler.pickup_item(pokemon.original)
      end
    end

    BattleEndHandler.register_no_defeat('PSDK power band') do |_, players_pokemon|
      players_pokemon.each do |pokemon|
        next unless pokemon.original.item_db_symbol == :power_band

        pokemon.add_ev_dfs(4, pokemon.original.total_ev)
      end
    end

    BattleEndHandler.register_no_defeat('PSDK power belt') do |_, players_pokemon|
      players_pokemon.each do |pokemon|
        next unless pokemon.original.item_db_symbol == :power_belt

        pokemon.add_ev_dfe(4, pokemon.original.total_ev)
      end
    end

    BattleEndHandler.register_no_defeat('PSDK power anklet') do |_, players_pokemon|
      players_pokemon.each do |pokemon|
        next unless pokemon.original.item_db_symbol == :power_anklet

        pokemon.add_ev_spd(4, pokemon.original.total_ev)
      end
    end

    BattleEndHandler.register_no_defeat('PSDK power lens') do |_, players_pokemon|
      players_pokemon.each do |pokemon|
        next unless pokemon.original.item_db_symbol == :power_lens

        pokemon.add_ev_ats(4, pokemon.original.total_ev)
      end
    end

    BattleEndHandler.register_no_defeat('PSDK power weight') do |_, players_pokemon|
      players_pokemon.each do |pokemon|
        next unless pokemon.original.item_db_symbol == :power_weight

        pokemon.add_ev_hp(4, pokemon.original.total_ev)
      end
    end

    BattleEndHandler.register_no_defeat('PSDK power bracer') do |_, players_pokemon|
      players_pokemon.each do |pokemon|
        next unless pokemon.original.item_db_symbol == :power_bracer

        pokemon.add_ev_atk(4, pokemon.original.total_ev)
      end
    end

    BattleEndHandler.register('PSDK form calibration') do |_, players_pokemon|
      players_pokemon.each(&:unmega_evolve)
      players_pokemon.each(&:form_calibrate)
    end

    BattleEndHandler.register('PSDK burmy & wormadam calibration') do |_, players_pokemon|
      players_pokemon.each do |pokemon|
        next unless pokemon.db_symbol == :burmy || pokemon.db_symbol == :wormadam

        pokemon.form = pokemon.form_generation(-1)
      end
    end

    BattleEndHandler.register_no_defeat('PSDK Evolve') do |handler, players_pokemon|
      players_pokemon.each do |pokemon|
        next unless handler.logic.evolve_request.include?(pokemon) && pokemon.alive?

        original = pokemon.original
        id, form = original.evolve_check(:level_up)
        handler.scene.instance_variable_set(:@cfi_type, :none) # Prevent fade in in case of multiple evolution
        next unless id

        GamePlay.make_pokemon_evolve(original, id, form)
        $pokedex.mark_seen(original.id, original.form, forced: true)
        $pokedex.mark_captured(original.id)
        $quests.see_pokemon(original.id)
        $quests.catch_pokemon(original)
        pokemon.id = original.id
        pokemon.form = original.form
      end
    end

    BattleEndHandler.register('PSDK stop cycling') do |_, players_pokemon|
      $game_player.leave_cycling_state if players_pokemon.all?(&:dead?) && !$game_temp.battle_can_lose
    end

    BattleEndHandler.register('PSDK send player back to Pokemon Center') do |handler, players_pokemon|
      next unless players_pokemon.all?(&:dead?)

      unless $game_temp.battle_can_lose
        handler.player_loose_sequence
        $wild_battle.reset
        $game_temp.player_transferring = true
        $game_map.setup($game_temp.player_new_map_id = $game_variables[::Yuki::Var::E_Return_ID])
        $game_temp.player_new_x = $game_variables[::Yuki::Var::E_Return_X] + ::Yuki::MapLinker.get_OffsetX
        $game_temp.player_new_y = $game_variables[::Yuki::Var::E_Return_Y] + ::Yuki::MapLinker.get_OffsetY
        $game_temp.player_new_direction = 8
        $game_switches[Yuki::Sw::FM_NoReset] = true
        $game_temp.common_event_id = 3
      end
    end

    BattleEndHandler.register('PSDK Update Pokedex') do |handler|
      handler.logic.all_battlers { |battler| 
        next if battler.from_party? || battler.last_sent_turn == -1
        $pokedex.mark_seen(battler.id, battler.form, forced: true)
        $pokedex.pokemon_fought_inc(battler.id) unless battler.alive?
      }
    end

    BattleEndHandler.register('PSDK Update Quest') do |handler|
      handler.logic.all_battlers { |battler|
        next if battler.from_party?
        $quests.see_pokemon(battler.id) unless battler.last_sent_turn == -1
        $quests.beat_pokemon(battler.id) unless battler.alive?
      }
    end

    BattleEndHandler.register('PSDK give back the items for Bestow Effects') do |handler|
      next if (effects = handler.logic.terrain_effects.get_all(:bestow)).empty?

      effects.each(&:give_back_item)
    end

    BattleEndHandler.register_nuzlocke('PSDK Nuzlocke') do |handler|
      PFM.game_state.nuzlocke.clear_dead_pokemon
      handler.logic.all_battlers do |battler|
        PFM.game_state.nuzlocke.lock_catch_in_current_zone(battler.id) unless battler.from_party?
      end
      caught_pokemon = handler.logic.battle_info.caught_pokemon
      PFM.game_state.nuzlocke.lock_catch_in_current_zone(caught_pokemon.id) if caught_pokemon
    end
  end
end
