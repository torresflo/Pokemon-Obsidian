module Battle
  module AI
    class Base
      # List of boosting items
      BOOSTING_ITEMS = %i[x_attack x_sp_atk x_speed x_defense x_sp_def]
      # List of healing items
      HEALING_ITEMS = %i[full_restore hyper_potion energy_root moomoo_milk lemonade
                         super_potion energy_powder soda_pop fresh_water
                         potion berry_juice sweet_heart sitrus_berry oran_berry]
      # List of item that heal from poison
      POISON_HEAL_ITEMS = %i[antidote full_heal heal_powder lava_cookie
                             old_gateau pecha_berry lum_berry casteliacone
                             lumiose_galette shalour_sable]
      # List of item that heals from burn state
      BURN_HEAL_ITEMS = %i[burn_heal full_heal heal_powder lava_cookie
                           old_gateau rawst_berry lum_berry casteliacone
                           lumiose_galette shalour_sable]
      # List of item that heals from paralysis
      PARALYZE_HEAL_ITEMS = %i[paralyze_heal full_heal heal_powder lava_cookie
                               old_gateau cheri_berry lum_berry casteliacone
                               lumiose_galette shalour_sable]
      # List of item that heals from frozen state
      FREEZE_HEAL_ITEMS = %i[ice_heal full_heal heal_powder lava_cookie
                             old_gateau aspear_berry lum_berry casteliacone
                             lumiose_galette shalour_sable]
      # List of item that wake the Pokemon up
      WAKE_UP_ITEMS = %i[awakening full_heal heal_powder lava_cookie
                         old_gateau blue_flute chesto_berry lum_berry
                         casteliacone lumiose_galette shalour_sable]

      private

      # Generate the item action for the pokemon
      # @param pokemon [PFM::PokemonBattler]
      # @param move_heuristics [Array<Float>]
      # @return [Array<[Float, Actions::Item]>]
      def item_actions_for(pokemon, move_heuristics)
        actions = boost_item_actions_for(pokemon, move_heuristics)
        actions.concat(heal_item_actions_for(pokemon, move_heuristics)) if @can_heal && pokemon.hp_rate <= @heal_threshold
        actions.concat(status_heal_item_actions_for(pokemon, move_heuristics)) if @can_heal && pokemon.status != 0
        return actions
      end

      # Generate the boost item action for the pokemon
      # @param pokemon [PFM::PokemonBattler]
      # @param move_heuristics [Array<Float>]
      # @return [Array<[Float, Actions::Item]>]
      def boost_item_actions_for(pokemon, move_heuristics)
        interest_factor = boost_item_interest_factor_for(pokemon)
        BOOSTING_ITEMS.select { |item| pokemon.bag.contain_item?(item) }.map do |item|
          wrapper = PFM::ItemDescriptor.actions(item)
          if wrapper.on_pokemon_choice(pokemon, @scene) # WARNING: Check if there's message shown
            wrapper.bind(@scene, pokemon)
            next [interest_factor, Actions::Item.new(@scene, wrapper, pokemon.bag, pokemon)]
          else
            next nil
          end
        end.compact
      end

      # Get the boost item interest factor
      # @param pokemon [PFM::PokemonBattler]
      # @return [Float]
      def boost_item_interest_factor_for(pokemon)
        Math.exp((pokemon.last_sent_turn - $game_temp.battle_turn + 1) / 10.0) * 0.85
      end

      # Generate the heal item action for the pokemon
      # @param pokemon [PFM::PokemonBattler]
      # @param move_heuristics [Array<Float>]
      # @return [Array<[Float, Actions::Item]>]
      def heal_item_actions_for(pokemon, move_heuristics)
        HEALING_ITEMS.select { |item| pokemon.bag.contain_item?(item) }.map do |item|
          wrapper = PFM::ItemDescriptor.actions(item)
          wrapper.bind(@scene, pokemon)
          factor = (wrapper.item.is_a?(GameData::ConstantHealItem) ? wrapper.item.hp_count.to_f / pokemon.max_hp : wrapper.item.hp_rate) * 2.0
          next [factor, Actions::Item.new(@scene, wrapper, pokemon.bag, pokemon)]
        end.compact
      end

      # Generate the heal item action for the pokemon
      # @param pokemon [PFM::PokemonBattler]
      # @param move_heuristics [Array<Float>]
      # @return [Array<[Float, Actions::Item]>]
      def status_heal_item_actions_for(pokemon, move_heuristics)
        if pokemon.burn?
          items = BURN_HEAL_ITEMS
          rate = 1 - pokemon.hp_rate / 4
        elsif pokemon.poisoned? || pokemon.toxic?
          items = POISON_HEAL_ITEMS
          rate = 1 - pokemon.hp_rate / 4
        elsif pokemon.paralyzed?
          items = PARALYZE_HEAL_ITEMS
          rate = 0.78
        elsif pokemon.frozen?
          items = FREEZE_HEAL_ITEMS
          rate = 0.85
        elsif pokemon.asleep?
          items = WAKE_UP_ITEMS
          rate = 0.76
        end
        return items.select { |item| pokemon.bag.contain_item?(item) }.map do |item|
          wrapper = PFM::ItemDescriptor.actions(item)
          wrapper.bind(@scene, pokemon)
          next [rate, Actions::Item.new(@scene, wrapper, pokemon.bag, pokemon)]
        end.compact
      end
    end
  end
end
