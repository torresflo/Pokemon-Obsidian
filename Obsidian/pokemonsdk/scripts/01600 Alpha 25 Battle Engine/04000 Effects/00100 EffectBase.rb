module Battle
  module Effects
    # Class describing all the effect ("abstract") and helping the handler to manage effect
    class EffectBase
      # Create a new effect
      # @param logic [Battle::Logic] logic used to get all the handler in order to allow the effect to work
      def initialize(logic)
        @logic = logic
        # Counter so we can disable the effect
        # @type [Integer]
        @counter = Float::INFINITY
      end

      # Function that sets the counter
      # @param counter [Integer] new counter value
      def counter=(counter)
        @counter = counter.clamp(0, Float::INFINITY)
      end

      # Function that updates the counter of the effect
      def update_counter
        @counter -= 1
      end

      # Function telling if the effect should be removed from effects handler
      # @return [Boolean]
      def dead?
        @counter <= 0
      end

      # Function giving the name of the effect
      # @return [Symbol]
      def name
        return :base
      end

      # Kill the effect (in order to remove it from the effects handler)
      def kill
        @counter = -1
        disable_hooks
      end

      # Function called when the effect has been deleted from the effects handler
      def on_delete
        return nil
      end

      # Function that tells if the move is affected by Rapid Spin
      # @return [Boolean]
      def rapid_spin_affected?
        return false
      end

      # Tell if the effect forces the next move
      # @return [Boolean]
      def force_next_move?
        return false
      end

      # Tell if the effect make the pokemon out reach
      # @return [Boolean]
      def out_of_reach?
        return false
      end

      # Check if the attack can hit the pokemon. Should be called after testing out_of_reach?
      # @param name [Symbol]
      # @return [Boolean]
      def can_attack_hit_out_of_reach?(name)
        # (exemple) This is where we test earthquake, fissuer and magnitude for Dig
        return out_of_reach?
      end

      # Tell if the given battler is targetted by the effect
      # @param battler [PFM::PokemonBattler]
      # @return [Boolean]
      def targetted?(battler)
        false
      end

      # Function called when a held item wants to perform its action
      # @return [Boolean] weither or not the item can't proceed (true will stop the item)
      def on_held_item_use_prevention
        false
      end

      # Function called after a battler proceed its two turn move's first turn
      # @param user [PFM::PokemonBattler]
      # @param targets [Array<PFM::PokemonBattler>, nil]
      # @param skill [Battle::Move, nil]
      # @return [Boolean] weither or not the two turns move is executed in one turn
      def on_two_turn_shortcut(user, targets, skill)
        false
      end

      # Function called when a stat_increase_prevention is checked
      # @param handler [Battle::Logic::StatChangeHandler] handler use to test prevention
      # @param stat [Symbol] :atk, :dfe, :spd, :ats, :dfs, :acc, :eva
      # @param target [PFM::PokemonBattler]
      # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
      # @param skill [Battle::Move, nil] Potential move used
      # @return [:prevent, nil] :prevent if the stat increase cannot apply
      def on_stat_increase_prevention(handler, stat, target, launcher, skill)
        nil && handler && stat && target && launcher && skill
      end

      # Function called when a stat_decrease_prevention is checked
      # @param handler [Battle::Logic::StatChangeHandler] handler use to test prevention
      # @param stat [Symbol] :atk, :dfe, :spd, :ats, :dfs, :acc, :eva
      # @param target [PFM::PokemonBattler]
      # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
      # @param skill [Battle::Move, nil] Potential move used
      # @return [:prevent, nil] :prevent if the stat decrease cannot apply
      def on_stat_decrease_prevention(handler, stat, target, launcher, skill)
        nil && handler && stat && target && launcher && skill
      end

      # Function called when a stat_change is about to be applied
      # @param handler [Battle::Logic::StatChangeHandler]
      # @param stat [Symbol] :atk, :dfe, :spd, :ats, :dfs, :acc, :eva
      # @param power [Integer] power of the stat change
      # @param target [PFM::PokemonBattler]
      # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
      # @param skill [Battle::Move, nil] Potential move used
      # @return [Integer, nil] if integer, it will change the power
      def on_stat_change(handler, stat, power, target, launcher, skill)
        nil && handler && stat && target && launcher && skill
      end

      # Function called when a stat_change has been applied
      # @param handler [Battle::Logic::StatChangeHandler]
      # @param stat [Symbol] :atk, :dfe, :spd, :ats, :dfs, :acc, :eva
      # @param power [Integer] power of the stat change
      # @param target [PFM::PokemonBattler]
      # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
      # @param skill [Battle::Move, nil] Potential move used
      # @return [Integer, nil] if integer, it will change the power
      def on_stat_change_post(handler, stat, power, target, launcher, skill)
        nil && handler && stat && target && launcher && skill
      end

      # Function called when a pre_item_change is checked
      # @param handler [Battle::Logic::ItemChangeHandler]
      # @param db_symbol [Symbol] Symbol ID of the item
      # @param target [PFM::PokemonBattler]
      # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
      # @param skill [Battle::Move, nil] Potential move used
      # @return [:prevent, nil] :prevent if the item change cannot be applied
      def on_pre_item_change(handler, db_symbol, target, launcher, skill)
        nil && handler && db_symbol && target && launcher && skill
      end

      # Function called when a post_item_change is checked
      # @param handler [Battle::Logic::ItemChangeHandler]
      # @param db_symbol [Symbol] Symbol ID of the item
      # @param target [PFM::PokemonBattler]
      # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
      # @param skill [Battle::Move, nil] Potential move used
      def on_post_item_change(handler, db_symbol, target, launcher, skill)
        nil && handler && db_symbol && target && launcher && skill
      end

      # Function called when a status_prevention is checked
      # @param handler [Battle::Logic::StatusChangeHandler]
      # @param status [Symbol] :poison, :toxic, :confusion, :sleep, :freeze, :paralysis, :burn, :flinch, :cure
      # @param target [PFM::PokemonBattler]
      # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
      # @param skill [Battle::Move, nil] Potential move used
      # @return [:prevent, nil] :prevent if the status cannot be applied
      def on_status_prevention(handler, status, target, launcher, skill)
        nil && handler && status && target && launcher && skill
      end

      # Function called when a post_status_change is performed
      # @param handler [Battle::Logic::StatusChangeHandler]
      # @param status [Symbol] :poison, :toxic, :confusion, :sleep, :freeze, :paralysis, :burn, :flinch, :cure
      # @param target [PFM::PokemonBattler]
      # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
      # @param skill [Battle::Move, nil] Potential move used
      def on_post_status_change(handler, status, target, launcher, skill)
        nil && handler && status && target && launcher
      end

      # Function called when a damage_prevention is checked
      # @param handler [Battle::Logic::DamageHandler]
      # @param hp [Integer] number of hp (damage) dealt
      # @param target [PFM::PokemonBattler]
      # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
      # @param skill [Battle::Move, nil] Potential move used
      # @return [:prevent, Integer, nil] :prevent if the damage cannot be applied, Integer if the hp variable should be updated
      def on_damage_prevention(handler, hp, target, launcher, skill)
        nil && handler && hp && target && launcher && skill
      end

      # Function called after damages were applied (post_damage, when target is still alive)
      # @param handler [Battle::Logic::DamageHandler]
      # @param hp [Integer] number of hp (damage) dealt
      # @param target [PFM::PokemonBattler]
      # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
      # @param skill [Battle::Move, nil] Potential move used
      def on_post_damage(handler, hp, target, launcher, skill)
        nil && handler && hp && target && launcher && skill
      end

      # Function called after damages were applied and when target died (post_damage_death)
      # @param handler [Battle::Logic::DamageHandler]
      # @param hp [Integer] number of hp (damage) dealt
      # @param target [PFM::PokemonBattler]
      # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
      # @param skill [Battle::Move, nil] Potential move used
      def on_post_damage_death(handler, hp, target, launcher, skill)
        nil && handler && hp && target && launcher && skill
      end

      # Function called when testing if pokemon can switch regardless of the prevension.
      # @param handler [Battle::Logic::SwitchHandler]
      # @param pokemon [PFM::PokemonBattler]
      # @param skill [Battle::Move, nil] potential skill used to switch
      # @param reason [Symbol] the reason why the SwitchHandler is called
      # @return [:passthrough, nil] if :passthrough, can_switch? will return true without checking switch_prevention
      def on_switch_passthrough(handler, pokemon, skill, reason)
        nil && handler && pokemon && skill
      end

      # Function called when testing if pokemon can switch (when he couldn't passthrough)
      # @param handler [Battle::Logic::SwitchHandler]
      # @param pokemon [PFM::PokemonBattler]
      # @param skill [Battle::Move, nil] potential skill used to switch
      # @param reason [Symbol] the reason why the SwitchHandler is called
      # @return [:prevent, nil] if :prevent, can_switch? will return false
      def on_switch_prevention(handler, pokemon, skill, reason)
        nil && handler && pokemon && skill
      end

      # Function called when a Pokemon has actually switched with another one
      # @param handler [Battle::Logic::SwitchHandler]
      # @param who [PFM::PokemonBattler] Pokemon that is switched out
      # @param with [PFM::PokemonBattler] Pokemon that is switched in
      def on_switch_event(handler, who, with)
        nil && handler && who && with
      end

      # Function called at the end of a turn
      # @param logic [Battle::Logic] logic of the battle
      # @param scene [Battle::Scene] battle scene
      # @param battlers [Array<PFM::PokemonBattler>] all alive battlers
      def on_end_turn_event(logic, scene, battlers)
        nil && logic && scene && battlers
      end

      # Function called when a weather_prevention is checked
      # @param handler [Battle::Logic::WeatherChangeHandler]
      # @param weather_type [Symbol] :none, :rain, :sunny, :sandstorm, :hail, :fog
      # @param last_weather [Symbol] :none, :rain, :sunny, :sandstorm, :hail, :fog
      # @return [:prevent, nil] :prevent if the status cannot be applied
      def on_weather_prevention(handler, weather_type, last_weather)
        nil && handler && weather_type && last_weather
      end

      # Function called after the weather was changed (post_weather_change)
      # @param handler [Battle::Logic::WeatherChangeHandler]
      # @param weather_type [Symbol] :none, :rain, :sunny, :sandstorm, :hail, :fog
      # @param last_weather [Symbol] :none, :rain, :sunny, :sandstorm, :hail, :fog
      def on_post_weather_change(handler, weather_type, last_weather)
        nil && handler && weather_type && last_weather
      end

      # Function called when a fterrain_prevetion is checked
      # @param handler [Battle::Logic::FTerrainChangeHandler]
      # @param fterrain_type [Symbol] :none, :electric_terrain, :grassy_terrain, :misty_terrain, :psychic_terrain
      # @param last_fterrain [Symbol] :none, :electric_terrain, :grassy_terrain, :misty_terrain, :psychic_terrain
      # @return [:prevent, nil] :prevent if the status cannot be applied
      def on_fterrain_prevention(handler, fterrain_type, last_fterrain)
        nil && handler && fterrain_type && last_fterrain
      end

      # Function called after the weather was changed (post_weather_change)
      # @param handler [Battle::Logic::WeatherChangeHandler]
      # @param fterrain_type [Symbol] :none, :electric_terrain, :grassy_terrain, :misty_terrain, :psychic_terrain
      # @param last_fterrain [Symbol] :none, :electric_terrain, :grassy_terrain, :misty_terrain, :psychic_terrain
      def on_post_fterrain_change(handler, fterrain_type, last_fterrain)
        nil && handler && fterrain_type && last_fterrain
      end

      # Function called when we try to use a move as the user (returns :prevent if user fails)
      # @param user [PFM::PokemonBattler]
      # @param targets [Array<PFM::PokemonBattler>]
      # @param move [Battle::Move]
      # @return [:prevent, nil] :prevent if the move cannot continue
      def on_move_prevention_user(user, targets, move)
        nil && user && targets && move
      end

      # Function called when we try to check if the target evades the move
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler] expected target
      # @param move [Battle::Move]
      # @return [Boolean] if the target is evading the move
      def on_move_prevention_target(user, target, move)
        nil && user && target && move
      end

      # Function called when we try to get the definitive type of a move
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler] expected target
      # @param move [Battle::Move]
      # @param type [Integer] current type of the move (potentially after effects)
      # @return [Integer, nil] new type of the move
      def on_move_type_change(user, target, move, type)
        nil && user && target && move && type
      end

      # Function called when we try to check if the user cannot use a move
      # @param user [PFM::PokemonBattler]
      # @param move [Battle::Move]
      # @return [Proc, nil]
      def on_move_disabled_check(user, move)
        return nil
      end

      # Function called when we try to check if the effect changes the definitive priority of the move
      # @param user [PFM::PokemonBattler]
      # @param priority [Integer]
      # @param move [Battle::Move]
      # @return [Proc, nil]
      def on_move_priority_change(user, priority, move)
        return nil
      end

      # Function called when we try to check if the effect changes the definitive priority of the move
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler]
      # @param move [Battle::Move]
      # @return [Boolean] if the target is immune to the move
      def on_move_ability_immunity(user, target, move)
        return nil
      end

      # Function called when a Pokemon initialize a transformation
      # @param handler [Battle::Logic::TransformHandler]
      # @param target [PFM::PokemonBattler]
      def on_transform_event(handler, target)
        nil && handler && target
      end

      # Function that computes an overwrite of the type multiplier
      # @param target [PFM::PokemonBattler]
      # @param target_type [Integer] one of the type of the target
      # @param type [Integer] one of the type of the move
      # @param move [Battle::Move]
      # @return [Float, nil] overwriten type multiplier
      def on_single_type_multiplier_overwrite(target, target_type, type, move)
        nil && target && target_type && type && move
      end

      # Give the move base power mutiplier
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @param move [Battle::Move] move
      # @return [Float, Integer] multiplier
      def base_power_multiplier(user, target, move)
        return 1
      end

      # Give the move [Spe]atk mutiplier
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @param move [Battle::Move] move
      # @return [Float, Integer] multiplier
      def sp_atk_multiplier(user, target, move)
        return 1
      end

      # Give the move [Spe]def mutiplier
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @param move [Battle::Move] move
      # @return [Float, Integer] multiplier
      def sp_def_multiplier(user, target, move)
        return 1
      end

      # Give the move mod1 mutiplier (before the +2 in the formula)
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @param move [Battle::Move] move
      # @return [Float, Integer] multiplier
      def mod1_multiplier(user, target, move)
        return 1
      end

      # Give the move mod1 mutiplier (after the critical)
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @param move [Battle::Move] move
      # @return [Float, Integer] multiplier
      def mod2_multiplier(user, target, move)
        return 1
      end

      # Give the move mod3 mutiplier (after everything)
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @param move [Battle::Move] move
      # @return [Float, Integer] multiplier
      def mod3_multiplier(user, target, move)
        return 1
      end

      # Give the speed modifier over given to the Pokemon with this effect
      # @return [Float, Integer] multiplier
      def spd_modifier
        return 1
      end

      # Return the chance of hit multiplier
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @param move [Battle::Move]
      # @return [Float]
      def chance_of_hit_multiplier(user, target, move)
        return 1
      end

      private

      # Function that disable all the hooks (putting aside on_delete)
      def disable_hooks
        class << self
          def on_stat_increase_prevention(*)
            return nil
          end

          def base_power_multiplier(*)
            return 1
          end
          alias on_held_item_use_prevention on_stat_increase_prevention
          alias on_two_turn_shortcut on_stat_increase_prevention
          alias on_stat_decrease_prevention on_stat_increase_prevention
          alias on_stat_change on_stat_increase_prevention
          alias on_stat_change_post on_stat_increase_prevention
          alias on_pre_item_change on_stat_increase_prevention
          alias on_post_item_change on_stat_increase_prevention
          alias on_status_prevention on_stat_increase_prevention
          alias on_post_status_change on_stat_increase_prevention
          alias on_damage_prevention on_stat_increase_prevention
          alias on_post_damage on_stat_increase_prevention
          alias on_post_damage_death on_stat_increase_prevention
          alias on_switch_passthrough on_stat_increase_prevention
          alias on_switch_prevention on_stat_increase_prevention
          alias on_switch_event on_stat_increase_prevention
          alias on_end_turn_event on_stat_increase_prevention
          alias on_weather_prevention on_stat_increase_prevention
          alias on_post_weather_change on_stat_increase_prevention
          alias on_fterrain_prevention on_stat_increase_prevention
          alias on_post_fterrain_change on_stat_increase_prevention
          alias on_move_prevention_user on_stat_increase_prevention
          alias on_move_prevention_target on_stat_increase_prevention
          alias on_move_type_change on_stat_increase_prevention
          alias on_move_disabled_check on_stat_increase_prevention
          alias on_move_priority_change on_stat_increase_prevention
          alias on_move_ability_immunity on_stat_increase_prevention
          alias on_transform_event on_stat_increase_prevention
          alias on_single_type_multiplier_overwrite on_stat_increase_prevention
          alias sp_atk_multiplier base_power_multiplier
          alias sp_def_multiplier base_power_multiplier
          alias mod1_multiplier base_power_multiplier
          alias mod2_multiplier base_power_multiplier
          alias mod3_multiplier base_power_multiplier
          alias spd_modifier base_power_multiplier
          alias chance_of_hit_multiplier base_power_multiplier
        end
      end
    end
  end
end
