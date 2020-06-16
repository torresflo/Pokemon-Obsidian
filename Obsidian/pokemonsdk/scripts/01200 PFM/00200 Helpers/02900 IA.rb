module PFM
  # IA of PSDK (not coded yet)
  # @author Nuri Yuri
  module IA
    module_function
    extend ::Util::TargetSelection
    # Start the IA
    # @return [Array] list of IA actions
    def start
      #> Récupération des combattants
      @enemies_o = @enemies = ::BattleEngine.get_enemies
      @actors_o = @actors = ::BattleEngine.get_actors
      ::BattleEngine._enable_ia #>Indication que l'IA travaille
      #> Initialisation des résultats
      @results = []
      #> Initialisation des infos
      @IA_Info = {}
      #> Réalisation des calculs
      i = 0
      $game_temp.vs_type.times do |i|
        process_ia(@enemies_o[i]) unless check_cant_IA(@enemies_o[i])
      end
      #> Indication que le travail est fini
      ::BattleEngine._disable_ia
      return @results
    end
    # Add an attack to the stack
    # @param skill_index [Integer] Index of the skill in the Pokemon skill set
    # @param target_position [Integer, nil] Position of the enemy target (optional)
    # @param target_list [Array<PFM::Pokemon>] list of targets (required if target_position ommited)
    # @param launcher [PFM::Pokemon] launcher of the move
    def _stack_add_attack(skill_index: nil, target_position: nil,  target_list: nil, launcher: nil)
      if target_list
        target = target_list
        target_list.each_with_index do |pokemon, i|
          target_list[i] = get_pokemon_o(pokemon)
        end
      else
        target = -target_position - 1
      end
      launcher = get_pokemon_o(launcher)
      # Dirty Mega evolution add
      if BattleEngine.can_pokemon_mega_evolve?(launcher, get_bag(launcher))
        BattleEngine.prepare_mega_evolve(launcher, get_bag(launcher))
      end
      @results << [0, skill_index, target, launcher]
    end
    # Add a switch action to the stack
    # @param new_pokemon_index [Integer] index of the new Pokemon in the @enemies stack
    # @param current_pokemon_index [Integer] index of the current Pokemon in tge @enemies stack
    def _stack_add_switch(new_pokemon_index: 1, current_pokemon_index: 0)
      @results << [2, -new_pokemon_index - 1, current_pokemon_index]
    end
    # Add a flee action to the stack
    # @param pokemon [PFM::Pokemon] the pokemon that run away
    # @param reason [Symbol] the reason invoked to let the Pokemon run away
    def _stack_add_flee(pokemon: nil, reason: :roaming)
      @results << [3, get_pokemon_o(pokemon), reason]
    end
    # Add an item use action to the stack
    # @param pokemon [PFM::Pokemon] the pokemon that use the item
    # @param item_id [Integer, Symbol] id of the item
    # @param bag [PFM::Bag] the bag that contain the item
    # @return [Boolean]
    def _stack_add_item(pokemon: nil, item_id: 0, bag: nil)
      item_id = GameData::Item[item_id].id
      extend_data = ::PFM::ItemDescriptor.actions(item_id)
      if extend_data and extend_data[:action_to_push]
        @results << [1, [item_id, extend_data, pokemon.position]]
        bag.drop_item(item_id, 1)
        return true
      else
        return false
      end
    end
    # Check if the IA can't work on a specific pokemon
    # @param pkmn [PFM::Pokemon]
    # @return [Boolean]
    def check_cant_IA(pkmn)
      return true unless pkmn
      return true if pkmn.dead?
      #>Attaque forcée
      if(pkmn.battle_effect.has_forced_attack?)
        _stack_add_attack(
          skill_index: pkmn.battle_effect.get_forced_attack(pkmn),
          target_position: pkmn.battle_effect.get_forced_position,
          launcher: pkmn
        )
        #@results.push([0,pkmn.battle_effect.get_forced_attack(pkmn),
        #-pkmn.battle_effect.get_forced_position-1,pkmn])
        return true
      #>Si lutte car pas de skills viable
      elsif(BattleEngine::_lutte?(pkmn))
        _stack_add_attack(target_position: rand($game_temp.vs_type), launcher: pkmn)
        #@results.push([0,nil,-rand($game_temp.vs_type)-1,pkmn])
        return true
      elsif(pkmn.battle_effect.has_encore_effect?)
        _stack_add_attack(
          skill_index: pkmn.skills_set.index(pkmn.battle_effect.encore_skill).to_i,
          target_list: util_targetselection_automatic(pkmn, pkmn.battle_effect.encore_skill),
          launcher: pkmn
        )
        #@results.push([0,pkmn.skills_set.index(pkmn.battle_effect.encore_skill).to_i,
        #util_targetselection_automatic(pkmn, pkmn.battle_effect.encore_skill),pkmn])
        return true
      end
      return false
    end
    # Process the IA calculation
    # @param pokemon [PFM::Pokemon] the pokemon to process
    def process_ia(pokemon)
      if !$game_temp.trainer_battle and $wild_battle.is_roaming?(pokemon) and BattleEngine::_can_switch(get_pokemon(pokemon))
        return _stack_add_flee(pokemon: pokemon)#@results<<[3, pokemon, :roaming]
      end
      skill = nil
      skills_set = pokemon.skills_set
      be = pokemon.battle_effect
      i = 0
      j = 0
      ia_results = []
      #> Moulinette dans les skills
      4.times do |i|
        skill = skills_set[i]
        break unless skill
        #> Entrave
        if(be.has_disable_effect? and skill.id == be.disable_skill_id)
          puts "#{skill} sous entrave"
          next
        end
        pokemon = get_pokemon(pokemon)
        #> Moulinette dans les cibles
        if $game_temp.vs_type == 1
          if skill.target == :user or skill.target == :user_or_adjacent_ally or skill.target == :all_ally
            ia_results << skill_heuristic_calculation(pokemon, pokemon, skill, i)
          else
            ia_results << skill_heuristic_calculation(pokemon, @actors[0], skill, i)
          end
        else
          targets = util_targetselection_get_possible(pokemon, skill)
          unless targets
            if skill.target == :user
              ia_results << skill_heuristic_calculation(pokemon, pokemon, skill, i)
              next
            else
              case skill.target
              when :adjacent_all_foe      #  e! e! ex / ux ax ax
                targets = util_targetselection_adjacent_foe(pokemon)
              when :all_foe               #  e! e! e! / ux ax ax
                targets = ::BattleEngine.get_enemies!(pokemon)
              when :adjacent_all_pokemon  #  e! e! ex / ux a! ax
                targets = util_targetselection_adjacent_pokemon(pokemon)
              when :all_ally              #  ex ex ex / u! a! a!
                targets = ::BattleEngine.get_ally!(pokemon)
              else
                targets = ::BattleEngine.get_enemies!(pokemon)
              end
            end
          end
          targets.each do |target|
            ia_results << skill_heuristic_calculation(pokemon, target, skill, i)
          end
        end
=begin
        $game_temp.vs_type.times do |j|
          if(@actors[j] and @actors[j].hp > 0)
            ia_results << skill_heuristic_calculation(pokemon, @actors[j], skill, i)
          end
        end
=end
      end
      ia_results.sort! do |a,b|
        b[:value] <=> a[:value]
      end
      result = ia_results[0]
      if (result[:damage].to_i < pokemon.max_hp / 4) or (pokemon.hp_rate < 0.25) or !result[:faster]
        return if check_switch(get_pokemon(pokemon))
        return if check_item_heal(get_pokemon(pokemon))
      end
      return if result[:value] <= 0 and try_switch(pokemon)

      result = ia_results[rand(ia_results.size).to_i] if result[:value] <= 0
      if(result[:skill])
        if result[:skill_data].is_no_choice_skill? #> Pas de choix de cible
          _stack_add_attack(
            skill_index: result[:skill],
            target_list: util_targetselection_automatic(pokemon,result[:skill_data]),
            launcher: pokemon
          )
          #@results<<[0, result[:skill], util_targetselection_automatic(pokemon,result[:skill_data]), pokemon]
        else
          _stack_add_attack(
            skill_index: result[:skill],
            target_list: [result[:target] < 0 ? @actors[-result[:target]-1] : @enemies[result[:target]]],
            launcher: pokemon
          )
          #@results<<[0, result[:skill], [result[:target] < 0 ? @actors[-result[:target]-1] : @enemies[result[:target]]], pokemon]
        end
      else

      end
    end
    # Calculate the skill heuristic
    # @note Currently it doesn't take the attaking first or last thing in attack (could make potential errors)
    # @param launcher [PFM::Pokemon] the lancher of the attack
    # @param target [PFM::Pokemon] the target of the attack
    # @param skill [PFM::Skill] the skill used to attack
    # @param index [Integer] the index of the skill in the launcher's moveset
    # @return [Hash] an heuristic data, the key value contain the value of the final heuristic
    def skill_heuristic_calculation(launcher, target, skill, index)
      ::BattleEngine._load_ia_state
      #> Récupération des combattants
      @enemies = ::BattleEngine.get_enemies
      @actors = ::BattleEngine.get_actors

      launcher = get_pokemon(launcher)
      target = get_pokemon(target)
      @IA_Info.clear
      @IA_Info[:launcher] = launcher
      @IA_Info[:target] = target
      @IA_Info[:damage] = 0
      @IA_Info[:recoil] = 0
      @IA_Info[:symbol] = skill.symbol
      @IA_Info[:failure] = false
      @IA_Info[:skill] = skill
      heuristic = {:value => 0}
      heuristic[:skill] = index
      heuristic[:skill_data] = skill
      heuristic[:target] = -target.position-1
      heuristic[:faster] = launcher.spd >= target.spd
      BattleEngine::use_skill(launcher, [target], skill) unless special_skill(launcher, target, skill)
      enemy = target.position >= 0 
      enemy = true if seviper_zangoose_detect(launcher, target)
      if @IA_Info[:damage] > 0
        hp_scale = target.hp
        if (hp_scale / launcher.max_hp) > 2
          hp_scale = launcher.hp
        end
        value = @IA_Info[:damage] / hp_scale.to_f - @IA_Info[:recoil] / launcher.hp.to_f
        value *= -1 unless enemy
        heuristic[:value] += value
      end
      if @IA_Info[:other_factor]
        heuristic[:value] += @IA_Info[:other_factor]
      end
      if @IA_Info[:status_factor]
        value = @IA_Info[:status_chance] ? @IA_Info[:status_chance] : 1
        heuristic[:value] += @IA_Info[:status_factor] * value
      end
      if @IA_Info[:randomness]
        heuristic[:value] *= @IA_Info[:randomness]
      end
      heuristic[:damage] = @IA_Info[:damage]
      pc skill.name
      pc heuristic[:value]
      return heuristic
    end
    # Perform actions on special skills and tell it was a special skill or not
    # @param launcher [PFM::Pokemon]
    # @param target [PFM::Pokemon]
    # @param skill [PFM::Skill]
    def special_skill(launcher, target, skill)
      case skill.symbol
      when :s_counter #Riposte & co
        if skill.id == 64 and (count = target.skill_category_amount(1)) > 0
          @IA_Info[:other_factor] = rand * 0.6 + count * 0.1
        elsif skill.id == 243 and (count = target.skill_category_amount(2)) > 0
          @IA_Info[:other_factor] = rand * 0.6 + count * 0.1
        else
          @IA_Info[:other_factor] = rand * 0.7
        end
      else
        return false
      end
      return true
    end
    # List of item that heal from poison
    PoisonHealItems = %i[antidote full_heal heal_powder lava_cookie
                         old_gateau pecha_berry lum_berry casteliacone
                         lumiose_galette shalour_sable]
    # List of item that heals from burn state
    BurnHealItems = %i[burn_heal full_heal heal_powder lava_cookie
                       old_gateau rawst_berry lum_berry casteliacone
                       lumiose_galette shalour_sable]
    # List of item that heals from paralysis
    ParalyzeHealItems = %i[paralyze_heal full_heal heal_powder lava_cookie
                           old_gateau cheri_berry lum_berry casteliacone
                           lumiose_galette shalour_sable]
    # List of item that heals from frozen state
    FreezeHealItems = %i[ice_heal full_heal heal_powder lava_cookie
                         old_gateau aspear_berry lum_berry casteliacone
                         lumiose_galette shalour_sable]
    # List of item that wake the Pokemon up
    WakeUpItems = %i[awakening full_heal heal_powder lava_cookie
                     old_gateau blue_flute chesto_berry lum_berry
                     casteliacone lumiose_galette shalour_sable]
    # List of item that heals more than 60 HP
    ItemHealingMoreThan60 = %i[hyper_potion energy_root moomoo_milk lemonade]
    # List of item that heals more than 20 HP
    ItemHealingMoreThan20 = %i[super_potion energy_powder soda_pop fresh_water]
    # List of item that heals hp (less than 20)
    ItemHealingHP = %i[potion berry_juice sweet_heart sitrus_berry oran_berry]
    # Check if the Pokemon needs to use an heal item and use it
    # @param pokemon [PFM::Pokemon]
    # @return [Boolean] used an item => return
    def check_item_heal(pokemon)
      return false unless $game_temp.trainer_battle
      is_last = (@enemies.count { |pkmn| !pkmn.dead? }) == 1
      max_hp = pokemon.max_hp
      dhp = max_hp - pokemon.hp
      bag = get_bag(pokemon)
      has_full_restore = bag.contain_item?(:full_restore)
      has_full_restore = false unless is_last or bag.item_quantity(:full_restore) > 1
      has_full_restore = false if dhp < 60 # Don't use the fullrestore at this point
      #> Soin status
      if pokemon.status != 0 and pokemon.hp_rate > 0.5
        if pokemon.poisoned?
          return true if perform_status_heal(bag, has_full_restore, *PoisonHealItems)
        elsif pokemon.burnt?
          return true if perform_status_heal(bag, has_full_restore, *BurnHealItems)
        elsif pokemon.paralyzed?
          return true if perform_status_heal(bag, has_full_restore, *ParalyzeHealItems)
        elsif pokemon.frozen?
          return true if perform_status_heal(bag, has_full_restore, *FreezeHealItems)
        elsif pokemon.asleep?
          return true if perform_status_heal(bag, has_full_restore, *WakeUpItems)
        end
      end
      #> Soin HP
      if pokemon.hp_rate < 0.25
        if dhp > 120 and has_full_restore
          return _stack_add_item(pokemon: pokemon, item_id: :full_restore, bag: bag)
        elsif dhp > 120 and bag.contain_item?(:max_potion)
          return _stack_add_item(pokemon: pokemon, item_id: :max_potion, bag: bag)
        end
        # Test items healing more than 60 HP
        if dhp > 60
          ItemHealingMoreThan60.each do |sym|
            return _stack_add_item(pokemon: pokemon, item_id: sym, bag: bag) if bag.contain_item?(sym)
          end
        end
        # Itest items healing more than 20 HP
        if dhp > 20
          ItemHealingMoreThan20.each do |sym|
            return _stack_add_item(pokemon: pokemon, item_id: sym, bag: bag) if bag.contain_item?(sym)
          end
        end
        ItemHealingHP.each do |sym|
          return _stack_add_item(pokemon: pokemon, item_id: sym, bag: bag) if bag.contain_item?(sym)
        end
      end
      return false
    end
    # Perform a status heal if possible
    # @param bag [PFM::Bag] the bag that contain the item
    # @param has_full_restore [Boolean] if fullrestore can be triggered
    # @param item_ids [Array<Integer, Symbol>]
    # @return [Boolean]
    def perform_status_heal(bag, has_full_restore, *item_ids)
      if has_full_restore
        return _stack_add_item(pokemon: pokemon, item_id: :full_restore, bag: bag)
      else
        item_ids.each do |id|
          if bag.contain_item?(id)
            return _stack_add_item(pokemon: pokemon, item_id: id, bag: bag)
          end
        end
      end
      return false
    end
    # Return the bag associated to a specific Pokemon
    # @param pokemon [PFM::Pokemon]
    # @return [PFM::Bag]
    def get_bag(pokemon)
      return $scene.enemy_party.bag
    end
    # Check if the Pokemon needs to switch
    # @param pokemon [PFM::Pokemon]
    # @return [Boolean] switched => return
    def check_switch(pokemon)
      return false unless $game_temp.trainer_battle
      return false unless BattleEngine::_can_switch(pokemon = get_pokemon(pokemon))
      enemies = @actors[0...$game_temp.vs_type]
      enemies.delete_if { |pkmn| pkmn.dead? }
      return false if enemies.size == 0
      weak_count = 0
      enemies.each do |pkmn|
        weak_count += 1 if is_pokemon_strong_against(pkmn, pokemon) and !is_pokemon_strong_against(pokemon, pkmn)
      end
      if weak_count == enemies.size
        potential_switch = @enemies[$game_temp.vs_type..-1]
        trainer_id = pokemon.trainer_id
        potential_switch.delete_if { |pkmn| pkmn.dead? or trainer_id != pkmn.trainer_id }
        enemies.each do |enemy|
          switches_efficient = Array.new(potential_switch.size) { |i| is_pokemon_strong_against(potential_switch[i], enemy) }
          if index = switches_efficient.index(true)
            _stack_add_switch(
              new_pokemon_index: @enemies.index(potential_switch[index]),
              current_pokemon_index: @enemies.index(pokemon)
            )
            return true
          end
        end
      end
      return false
    end
    # Try to force switch a Pokemon
    # @param pokemon [PFM::Pokemon]
    # @return [Boolean] if it was a success
    def try_switch(pokemon)
      return false unless $game_temp.trainer_battle
      return false unless BattleEngine::_can_switch(pokemon = get_pokemon(pokemon)) or pokemon.dead?
      potential_switch = @enemies[$game_temp.vs_type..-1]
      trainer_id = pokemon.trainer_id
      potential_switch.delete_if { |pkmn| pkmn.dead? or trainer_id != pkmn.trainer_id }
      if potential_switch.size > 0
        $game_temp.vs_type.times do |j|
          next unless (enemy = @actors[j]) and !enemy.dead? or pokemon.dead?
          switches_efficient = Array.new(potential_switch.size) { |i| is_pokemon_strong_against(potential_switch[i], enemy) }
          if index = switches_efficient.index(true)
            _stack_add_switch(
              new_pokemon_index: @enemies.index(potential_switch[index]),
              current_pokemon_index: @enemies.index(pokemon)
            )
            return true
          elsif index = switches_efficient.index(false)
            _stack_add_switch(
              new_pokemon_index: @enemies.index(potential_switch[index]),
              current_pokemon_index: @enemies.index(pokemon)
            )
            return true
          elsif pokemon.dead? and (index = switches_efficient.index(nil))
            _stack_add_switch(
              new_pokemon_index: @enemies.index(potential_switch[index]),
              current_pokemon_index: @enemies.index(pokemon)
            )
            return true
          end
        end
      end
      return false
    end
    # Guess if the launcher is strong against the target
    # @param launcher [PFM::Pokemon] the launcher pokemon
    # @param target [PFM::Pokemon] the target pokemon
    # @return [true, false, nil] true = strong, nil = can't do anything, false = not strong against target
    def is_pokemon_strong_against(launcher, target)
      useless = true
      max_mod = 0
      # Useless check
      launcher.skills_set.each do |skill|
        if !skill.status?
          if (mod = BattleEngine::_type_modifier_calculation(target, skill)) > 0
            useless = false
            max_mod = mod if mod > max_mod
          end
        end
      end
      return nil if useless
      return true if max_mod >= 2
      return false
    end
    # Request a switch action to the IA
    # @param pokemon [PFM::Pokemon]
    # @return [Array, false] action if success
    def request_switch(pokemon)
      #> Récupération des combattants
      @enemies_o = @enemies = ::BattleEngine.get_enemies
      @actors_o = @actors = ::BattleEngine.get_actors
      ::BattleEngine._enable_ia #>Indication que l'IA travaille
      #> Initialisation des résultats
      @results = []
      #> Initialisation des infos
      @IA_Info = {}
      #> Réalisation des calculs
      state = try_switch(pokemon)
      #> Indication que le travail est fini
      ::BattleEngine._disable_ia
      return (state ? @results.first : false)
    end
    #<<Battle Engine Related stuff>>#

    
    # Process a message from the BattleEngine
    # @param msg [Array]
    def process_message(msg)
      launcher = @IA_Info[:launcher]
      case msg.first
      when :msg_fail, :unefficient_msg, :useless_msg
        @IA_Info[:failure] = true
      when :efficiency_sound
        @IA_Info[:failure] = true if msg.last == 0
      when :hp_down, :hp_down_proto
        if msg[1] == launcher
          @IA_Info[:recoil] += msg[2] if @IA_Info[:symbol] != :s_explosion
        else
          @IA_Info[:damage] += msg[2]
        end
      when :hp_up
        if msg.first == launcher
          @IA_Info[:recoil] -= msg[2]
        else
          @IA_Info[:damage] -= msg[2]
        end
      when :OHKO
        if msg[1] == launcher
          @IA_Info[:recoil] += msg[1].max_hp
        else
          @IA_Info[:damage] += msg[1].max_hp
        end
      when :rand_check
        @IA_Info[:randomness] = msg[1] ? msg[1].to_f / msg.last : msg.last / 100.0
      when :weather_change
        unless BattleEngine.state[:air_lock]
          @IA_Info[:other_factor] = get_weather_advantage_factor(msg[1]) if $env.current_weather == 0
        end
      when :attract_effect
        if msg[1] == launcher
          @IA_Info[:other_factor] = 0.1
        else
          @IA_Info[:other_factor] = get_attract_factor(msg[1])
        end
      when :effect_afraid
        @IA_Info[:status_factor] = rand
      when :status_confuse
        unless @IA_Info[:target].confused?
          @IA_Info[:status_factor] = rand * turn_status_factor(launcher) unless detect_protect_on_status(msg[1], false)
        end
      when :perish_song
        unless @IA_Info[:target].battle_effect.has_perish_song_effect? or launcher.battle_effect.has_perish_song_effect?
          @IA_Info[:other_factor] = get_basic_factor
        end
      when :future_skill
        @IA_Info[:other_factor] = get_basic_factor unless @IA_Info[:target].battle_effect.is_locked_by_future_skill? or launcher.battle_effect.has_future_skill?
      when :stat_reset_neg, :stat_reset
        @IA_Info[:other_factor] = get_basic_factor if launcher.battle_stage.sum < 0
      when :stat_set
        if msg[1] == launcher
          if msg.last > 0
            @IA_Info[:other_factor] = get_basic_factor if (launcher.battle_stage[msg[2]] - msg.last) < 0
          end
        else
          if msg.last < 0
            @IA_Info[:other_factor] = get_basic_factor if (@IA_Info[:target].battle_stage[msg[2]] - msg.last) > 0
          end
        end
      when :set_type
        @IA_Info[:other_factor] = get_basic_factor unless msg[1].type?(msg[2])
      when :set_ability
        @IA_Info[:other_factor] = get_basic_factor unless msg[1].ability_current == msg[2]
      when :switch_pokemon
        @IA_Info[:other_factor] = get_basic_factor if launcher.hp_rate < 0.5
      when :mimic
        @IA_Info[:other_factor] = get_basic_factor if $game_temp.battle_turn > 1 and msg[2].last_skill != 0
      when :entry_hazards_remove
        if BattleEngine.state[:enn_spikes] > 0 or
          BattleEngine.state[:enn_toxic_spikes] > 0 or
          BattleEngine.state[:enn_stealth_rock] or
          BattleEngine.state[:enn_sticky_web]
          @IA_Info[:other_factor] = get_basic_factor(0.8)
        end
      when :apply_out_of_reach
        @IA_Info[:other_factor] = get_basic_factor
      when :set_hp
        if msg[1] == launcher
          @IA_Info[:recoil] += launcher.hp - msg[2]
        else
          @IA_Info[:damage] += @IA_Info[:target] - msg[2]
        end
      when :berry_use
        @IA_Info[:other_factor] = 0.2
      when :after_you
        @IA_Info[:other_factor] = get_basic_factor
      when :change_atk, :change_dfe, :change_spd, :change_dfs, :change_ats, :change_eva, :change_acc
        if msg[1] == launcher
          if msg.last > 0
            @IA_Info[:other_factor] = get_basic_factor if (launcher.battle_stage.sum - msg.last) < 0
          end
        else
          if msg.last < 0
            @IA_Info[:other_factor] = get_basic_factor if (@IA_Info[:target].battle_stage.sum - msg.last) > 0
          end
        end
      when :status_sleep
        unless detect_protect_on_status(msg[1])
          if msg[1].can_be_asleep?
            @IA_Info[:status_factor] = get_basic_factor * turn_status_factor(launcher)
          end
        end
      when :status_frozen
        unless detect_protect_on_status(msg[1])
          if msg[1].can_be_frozen?(@IA_Info[:skill].type)
            @IA_Info[:status_factor] = get_basic_factor * 2
          end
        end
      when :status_poison
        unless detect_protect_on_status(msg[1])
          if msg[1].can_be_poisoned?
            @IA_Info[:status_factor] = get_basic_factor * turn_status_factor(launcher)
          end
        end
      when :status_toxic
        unless detect_protect_on_status(msg[1])
          if msg[1].can_be_poisoned?
            @IA_Info[:status_factor] = get_basic_factor * 2
          end
        end
      when :status_paralyze
        unless detect_protect_on_status(msg[1])
          if msg[1].can_be_paralyzed?
            @IA_Info[:status_factor] = get_basic_factor * turn_status_factor(launcher)
          end
        end
      when :status_burn
        unless detect_protect_on_status(msg[1])
          if msg[1].can_be_burn?
            @IA_Info[:status_factor] = get_basic_factor * 2
          end
        end
      when :status_cure
        if msg[1].status != 0 and msg[1] == launcher
          @IA_Info[:status_factor] = get_basic_factor
        end
      when :set_state
        @IA_Info[:other_factor] = get_basic_factor(0.8) if BattleEngine.state[msg[1]] != msg[2]
      when :send_state
        @IA_Info[:other_factor] = get_basic_factor(0.6)
      when :apply_effect
        @IA_Info[:other_factor] = get_basic_factor(0.3)
      when :status_chance
        @IA_Info[:status_chance] = msg.last / 100.0
      when :chance
        @IA_Info[:randomness] = msg.last / 100.0
      end
    end
    # Detect a protection for status effect
    # @param pkmn [PFM::Pokemon]
    # @param check_status [Boolean]
    # @return [Boolean]
    def detect_protect_on_status(pkmn, check_status = true)
      return true if check_status and pkmn.status != 0
      return true if pkmn.battle_effect.has_substitute_effect? and pkmn != @IA_Info[:launcher]
      return true if pkmn.battle_effect.has_safe_guard_effect?
      return false
    end
    # Return a turn factor in order to prevent spam from an stat/status attack
    # @param launcher [PFM::Pokemon]
    # @return [Float]
    def turn_status_factor(launcher)
      if launcher.battle_turns >= 1
        return ((launcher.battle_turns % 2 == 0) ? 0.6 : 0.8)
      end
      return 1
    end
    # Get a basic factor
    # @return [Float]
    def get_basic_factor(value = 0.5)
      return value + rand % (1 - value)
    end
    # Get the attract factor
    # @param target [PFM::Pokemon]
    def get_attract_factor(target)
      launcher = @IA_Info[:launcher]
      unless target.battle_effect.has_attract_effect? or BattleEngine._has_item(target, 219)
        if ((target.gender * launcher.gender) == 2 and !BattleEngine::Abilities.has_ability_usable(target, 39))
          return get_basic_factor
        end
      end
      return 0
    end
    # Get the weather advantage factor // << Ajouter les propriétés de Morphéo
    # @param type [Symbol]
    def get_weather_advantage_factor(type)
      launcher = @IA_Info[:launcher]
      target = @IA_Info[:target]
      case type
      when :rain
        if launcher.type_water? or launcher.type_ice?
          unless target.type_water? or target.type_ice?
            return 1.0 / $game_temp.battle_turn
          end
        end
      when :sunny
        if launcher.type_fire? and !target.type_fire?
          return 1.0 / $game_temp.battle_turn
        end
      when :sandstorm
        if launcher.type_ground? or launcher.type_rock?
          unless target.type_ground? or target.type_rock?
            return 1.0 / $game_temp.battle_turn
          end
        end
      when :hail
        if launcher.type_ice? and !target.type_ice?
          return 1.0 / $game_temp.battle_turn
        end
      when :fog
        return 1.0 / $game_temp.battle_turn
      end
      return 0
    end
    # Retrieve the Pokemon when the Actor array changed
    # @param pokemon [PFM::Pokemon]
    # @return [PFM::Pokemon]
    def get_pokemon(pokemon)
      if pokemon.position >= 0
        return @actors[pokemon.position]
      end
      return @enemies[-pokemon.position-1]
    end
    # Retrieve the Pokemon from the original array
    # @param pokemon [PFM::Pokemon]
    # @return [PFM::Pokemon]
    def get_pokemon_o(pokemon)
      if pokemon.position >= 0
        return @actors_o[pokemon.position]
      end
      return @enemies_o[-pokemon.position-1]
    end
  end
end
