module PFM
  # Module that help item to be used by returning an "extend_data" that every interface can understand
  #   Structure of the extend_data returned
  #     no_effect: opt Boolean # The item has no effect
  #     chen: opt Boolean # The stalker also called Prof. Chen that tells you the item cannot be used there
  #     open_party: opt Boolean # If the item require the Party menu to be opened in selection mode
  #     on_pokemon_choice: opt Proc # The proc to check when the player select a Pokemon(parameter) (return a value usefull to the interface)
  #     on_pokemon_use: opt Proc # The proc executed on a Pokemon(parameter) when the item is used
  #     open_skill: opt Boolean # If the item require the Skill selection interface to be open
  #     open_skill_learn: opt Integer # ID of the skill to learn if the item require to Open the Skill learn interface
  #     on_skill_choice: opt Proc # Proc to call to validate the choice of the skill(parameter)
  #     on_skill_use: opt Proc # Proc to call when a skill(parameter) is validated and choosen 
  #     on_use: opt Proc # The proc to call when the item is used.
  #     action_to_push: opt Proc # The proc to call to push the specific action when the item is used in battle
  #     stone_evolve: opt Boolean # If a Pokemon evolve by stone
  #     use_before_telling: opt Boolean # If :on_use proc is called before telling the item is used
  #     skill_message_id: opt Integer # ID of the message to show in the win_text in the Summary
  #
  # @author Nuri Yuri
  module ItemDescriptor
    include GameData::SystemTags
    LVL_SOUND = 'audio/me/rosa_levelup'
    # Proc executed when there's no condition (returns true)
    NoCondition = proc { true }
    # Common event condition procs to call before calling event (common_event_id => proc { conditions })
    CommonEventConditions = {
      6 => NoCondition,
      7 => NoCondition,
      11 => proc do
        !$game_player.surfing? && ($game_switches[Yuki::Sw::EV_Bicycle] ||
        $game_switches[Yuki::Sw::Env_CanFly] ||
        $game_switches[Yuki::Sw::Env_CanDig])
      end,
      13 => proc { $game_switches[Yuki::Sw::Env_CanDig] },
      14 => proc { $game_switches[Yuki::Sw::Env_CanDig] },
      19 => NoCondition,
      22 => proc { Game_Character::SurfTag.include?($game_player.front_system_tag) },
      23 => proc { Game_Character::SurfTag.include?($game_player.front_system_tag) },
      24 => proc { Game_Character::SurfTag.include?($game_player.front_system_tag) },
      33 => proc do
        !$game_player.surfing? && ($game_switches[Yuki::Sw::EV_AccroBike] ||
        $game_switches[Yuki::Sw::Env_CanFly] ||
        $game_switches[Yuki::Sw::Env_CanDig])
      end
    }
    CommonEventConditions.default = NoCondition
    # No effect Hash descriptor
    NoEffect = { no_effect: true }
    # You cannot use this item here Hash descriptor
    Chen = { chen: true }
    # Stage boost method Symbol in PFM::Pokemon
    Boost = %i[change_atk change_dfe change_spd change_ats change_dfs change_eva change_acc]
    # Message text id of the various item heals (index => text_id)
    BagStatesHeal = [116, 110, 111, 112, 120, 113, 116, 116, 110]
    # Message text id of the various EV change (index => text_id)
    EVStat = [134, 129, 130, 133, 131, 132]

    module_function

    # Describe an item with a Hash descriptor
    # @param item_id [Integer] ID of the item in the database
    # @return [Hash] the Hash descriptor defined at the top of the doc page
    def actions(item_id)
      item = GameData::Item[item_id]
      # If the item exists
      return NoEffect unless GameData::Item.id_valid?(item.id)

      sym = item.db_symbol
      # If the item is usable in this context
      if $game_temp.in_battle
        return Chen unless item.battle_usable
      else
        return Chen unless item.map_usable
      end
      # If it's a ball
      if item.ball_data
        return { ball_data: item.ball_data } if $game_temp.in_battle && ::BattleEngine.count_alives == 1
        return Chen
      end
      hash = {}
      be = ::BattleEngine
      # If it's a lansat_berry or a dire_hit (Muscle+ / Baie Lensa)
      if sym == :dire_hit || sym == :lansat_berry
        hash[:open_party] = true
        hash[:on_pokemon_choice] = proc do |pkmn|
          next(true) if pkmn.critical_rate == 0
          next(false)
        end
        hash[:action_to_push] = proc do |pkmn|
          pkmn.critical_rate = 1
        end
        return hash
      # Or if it's the sacred_ash
      elsif sym == :sacred_ash
        usable = false
        $actors.each do |pkmn|
          usable = true if pkmn.hp <= 0 and !pkmn.egg?
        end
        return Chen unless usable
        hash[:on_use] = proc do
          $actors.each do |pkmn|
            next unless pkmn and pkmn.hp <= 0
            pkmn.cure
            pkmn.hp = pkmn.max_hp
            pkmn.skills_set.each do |j|
              next unless j
              j.pp = j.ppmax
            end
            $scene.display_message(parse_text(22, 115, be::PKNICK[0] => pkmn.given_name))
          end
        end
        return hash
      # If it's the honney
      elsif sym == :honey
        return Chen unless $env.normal? && !$env.grass? && !$env.building?
        hash[:on_use] = proc do
          if $wild_battle.available?
            $scene.return_to_scene(::Scene_Map)
            $game_system.map_interpreter.launch_common_event(1)
          else
            $scene.display_message(text_get(39, 7).clone)
          end
        end
        return hash
      end

      # If it's a healing item
      if (heal_data = item.heal_data)
        # If it heals hp, healing hp get the priority over other heals
        if (heal_data.hp && heal_data.hp > 0) || (heal_data.hp_rate && heal_data.hp_rate > 0)
          hash[:open_party] = true
          # We check the Pokemon lost HP
          hash[:on_pokemon_choice] = proc do |pkmn|
            next(false) if pkmn.egg?
            states = heal_data.states
            if states
              next(pkmn.hp <= 0) if(states.include?(GameData::States::DEATH)) # If it recovers from KO
              next(states.include?(pkmn.status) or (!pkmn.dead? and pkmn.hp < pkmn.max_hp)) # All other states
            else
              next(!pkmn.dead? && pkmn.hp < pkmn.max_hp) # If the Pokemon isn't KO
            end
          end
          if heal_data.hp && heal_data.hp > 0
            hp = heal_data.hp
          elsif heal_data.hp_rate && heal_data.hp_rate > 0
            hp = heal_data.hp_rate / 100.0
          end
          # In battle = action to push
          if $game_temp.in_battle
            # /!\ Incohérence d'une résurection d'un mort sur le banc
            hash[:action_to_push] = proc do |pkmn|
              pkmn.loyalty += heal_data.loyalty if heal_data.loyalty
              #> Cas où il a tout ses HP mais soin de statut
              pkstatus = pkmn.status || ((pkmn.status != 0 and pkmn.confused?) ? 6 : 0)
              if(states = heal_data.states and states.include?(pkstatus))
                if(pkmn.position and pkmn.position <= $game_temp.vs_type)
                  be._mp([:status_cure, pkmn])
                else
                  be._mp([:set_status, pkmn, 0])
                  be._msgp(22, BagStatesHeal[pkstatus], nil, be::PKNICK[0] => pkmn.given_name)
                end
                next if(pkmn.hp == pkmn.max_hp)
              end
              hp = hp.class == Float ? (pkmn.max_hp * hp).round : hp
              if(pkmn.position and pkmn.position <= $game_temp.vs_type and !pkmn.dead?)
                be._mp([:hp_up, pkmn, hp])
              else
                be._mp([:set_hp, pkmn, pkmn.hp + hp])
              end
              be._msgp(19, 387, pkmn)
              berry_check_bonus(item.misc_data, pkmn)
            end
          #> Hors combat on_pokemon_use
          else
            hash[:on_pokemon_use] = proc do |pkmn|
              pkmn.loyalty += heal_data.loyalty if heal_data.loyalty
              #> Cas où ça soigne aussi les statuts
              status = pkmn.status
              if(states = heal_data.states and states.include?(status))
                pkmn.status = 0
                $scene.display_message(parse_text(22, BagStatesHeal[status], be::PKNICK[0] => pkmn.given_name))
                next if(pkmn.hp == pkmn.max_hp)
              end
              hp = hp.class == Float ? (pkmn.max_hp * hp).round : hp
              base_hp = pkmn.hp
              pkmn.hp += hp
              if(base_hp <= 0)
                $scene.display_message(parse_text(22, 115, be::PKNICK[0] => pkmn.given_name))
              else
                $scene.display_message(parse_text(22, 109, be::PKNICK[0] => pkmn.given_name,
                be::NUM3[1] => (pkmn.hp - base_hp).to_s))
              end
              berry_check_bonus(item.misc_data, pkmn)
            end
          end

        #> Sinon on espère un soin de statut
        elsif (states = heal_data.states) && !states.empty?
          hash[:open_party] = true
          #> Le Pokémon doit avoir le status
          hash[:on_pokemon_choice] = proc do |pkmn|
            next(false) if pkmn.egg?
            states.include?(pkmn.status) || (pkmn.confused? and states.include?(GameData::States::CONFUSED))
          end
          #> En combat => action_to_push
          if($game_temp.in_battle)
            hash[:action_to_push] = proc do |pkmn|
              #> Si c'est l'adversaire ou un sur le terrain on doit traiter la chose différement
              if(pkmn.position and pkmn.position <= $game_temp.vs_type)
                be._mp([:status_cure, pkmn]) if states.include?(pkmn.status)
                be._mp([:confuse_cure, pkmn, GameData::Item[item_id].name]) if states.include?(GameData::States::CONFUSED)
              else
                be._mp([:set_status, pkmn, 0])
                be._msgp(22, BagStatesHeal[pkmn.status], nil, be::PKNICK[0] => pkmn.given_name)
              end
              pkmn.loyalty += heal_data.loyalty if heal_data.loyalty
              berry_check_bonus(item.misc_data, pkmn)
            end
          #> Hors combat on_pokemon_use
          else
            hash[:on_pokemon_use] = proc do |pkmn|
              status = pkmn.status
              pkmn.status = 0
              $scene.display_message(parse_text(22, BagStatesHeal[status], be::PKNICK[0] => pkmn.given_name))
              pkmn.loyalty += heal_data.loyalty if heal_data.loyalty
              berry_check_bonus(item.misc_data, pkmn)
            end
          end

        #> Sinon boost de stat
        elsif (boost = heal_data.battle_boost)
          return Chen unless $game_temp.in_battle
          hash[:open_party] = true
          #> Le Pokémon ne doit pas être au taquet (on est gentil)
          hash[:on_pokemon_choice] = proc do |pkmn|
            next(false) if pkmn.egg?
            pkmn.battle_stage[boost % 7] < 6
          end
          #> Génération de l'action en combat
          hash[:action_to_push] = proc do |pkmn|
            be._mp([Boost[boost % 7], pkmn, boost / 7 + 1])
            pkmn.loyalty += heal_data.loyalty.to_i unless pkmn.dead?
            berry_check_bonus(item.misc_data, pkmn)
          end

        #> Sinon boost EV de stat
        elsif (boost = heal_data.boost_stat)
          return Chen if $game_temp.in_battle
          hash[:open_party] = true
          #> Le Pokémon ne doit pas être au taquet (on est gentil)
          hash[:on_pokemon_choice] = proc do |pkmn|
            next(false) if pkmn.egg?
            pkmn.ev_check(boost)
          end
          hash[:on_pokemon_use] = proc do |pkmn|
            pkmn.ev_check(boost, true)
            $scene.display_message(parse_text(22, 118, 
              be::PKNICK[0] => pkmn.given_name,
              '[VAR EVSTAT(0001)]' => text_get(22, EVStat[boost%10])))
            pkmn.loyalty += heal_data.loyalty if heal_data.loyalty
          end
        #> Sinon ajout de PP (Toutes les attaques)
        elsif (pp = heal_data.all_pp)
          hash[:open_party] = true
          #> Le Pokémon doit avoir un PP de moins sur une attaque
          hash[:on_pokemon_choice] = proc do |pkmn|
            next(false) if pkmn.egg?
            result = false
            pkmn.skills_set.each do |skill|
              next unless skill
              if(skill.pp < skill.ppmax)
                result = true
                break
              end
            end
            result
          end
          #> En combat => action_to_push
          if($game_temp.in_battle)
            hash[:action_to_push] = proc do |pkmn|
              pkmn.skills_set.each do |skill|
                be._mp([:set_pp, skill, skill.pp + pp]) if skill
              end
              be._msgp(22, 114, nil, be::PKNICK[0] => pkmn.given_name)
              pkmn.loyalty += heal_data.loyalty if heal_data.loyalty
              berry_check_bonus(item.misc_data, pkmn)
            end
          #> Hors combat on_pokemon_use
          else
            hash[:on_pokemon_use] = proc do |pkmn|
              pkmn.skills_set.each do |skill|
                skill.pp += pp if skill
              end
              $scene.display_message(parse_text(22, 114, be::PKNICK[0] => pkmn.given_name))
              pkmn.loyalty += heal_data.loyalty if heal_data.loyalty
              berry_check_bonus(item.misc_data, pkmn)
            end
          end

        #> Si soin de PP (une attaque)
        elsif (pp = heal_data.pp)
          hash[:open_party] = true
          #> Le Pokémon doit avoir un PP de moins sur une attaque
          hash[:on_pokemon_choice] = proc do |pkmn|
            next(false) if pkmn.egg?
            result = false
            pkmn.skills_set.each do |skill|
              next unless skill
              if(skill.pp < skill.ppmax)
                result = true
                break
              end
            end
            result
          end
          #> On doit ouvrir l'interface des skills
          hash[:open_skill] = true
          #> L'attaque choisie ne doit pas avoir les PP au max
          hash[:on_skill_choice] = proc do |skill|
            skill.pp < skill.ppmax
          end
          # Add "Restore PP of which move?"
          hash[:skill_message_id] = 34
          #> En combat
          if($game_temp.in_battle)
            hash[:action_to_push] = proc do |pkmn, skill|
              be._mp([:set_pp, skill, skill.pp + pp]) if skill
              be._msgp(19, 390, pkmn, be::MOVE[1] => skill.name)
              pkmn.loyalty += heal_data.loyalty if heal_data.loyalty
              berry_check_bonus(item.misc_data, pkmn)
            end
          #> Hors combat on_pokemon_use
          else
            hash[:on_skill_use] = proc do |pkmn, skill|
              skill.pp += pp
              $scene.display_message(parse_text(22, 114, be::MOVE[0] => skill.name))
              pkmn.loyalty += heal_data.loyalty if heal_data.loyalty
              berry_check_bonus(item.misc_data, pkmn)
            end
          end

        #> Si Ajout de PP
        elsif (pp = heal_data.add_pp)
          return Chen if $game_temp.in_battle
          hash[:open_party] = true
          #> Le Pokémon doit avoir une attaque pouvant avoir plus de PP
          hash[:on_pokemon_choice] = proc do |pkmn|
            next(false) if pkmn.egg?
            result = false
            pkmn.skills_set.each do |skill|
              next unless skill
              if((skill.data.pp_max * 8 / 5) > skill.ppmax)
                result = true
                break
              end
            end
            result
          end
          #> On doit ouvrir l'interface des skills
          hash[:open_skill] = true
          # Add "Boost PP of which move?"
          hash[:skill_message_id] = 35
          #> L'attaque choisie ne doit pas avoir les PP au max
          hash[:on_skill_choice] = proc do |skill|
            (skill.data.pp_max * 8 / 5) > skill.ppmax
          end
          hash[:on_skill_use] = proc do |pkmn, skill|
            if pp == 2
              skill.ppmax = skill.data.pp_max * 8 / 5
            else
              skill.ppmax += skill.data.pp_max * 1 / 5
            end
            skill.pp += 99
            $scene.display_message(parse_text(22, 117, be::MOVE[0] => skill.name))
            pkmn.loyalty += heal_data.loyalty if heal_data.loyalty
            # berry_check_bonus(item.misc_data, pkmn)
          end
        #> Ajout d'un ou plusieurs niveaux
        elsif (level = heal_data.level)
          return Chen if($game_temp.in_battle)
          hash[:open_party] = true
          #> Le pokémon ne doit pas être au niveau max
          hash[:on_pokemon_choice] = proc do |pkmn|
            next(false) if pkmn.egg?
            pkmn.level < $pokemon_party.level_max_limit
          end
          #> Utilisation sur le Pokémon
          hash[:on_pokemon_use] = proc do |pkmn|
            level.times do |i|
              if(pkmn.level_up)
                list = pkmn.level_up_stat_refresh
                Audio.me_play(LVL_SOUND)
                $scene.display_message(parse_text(22, 128, 
                  be::PKNICK[0] => pkmn.given_name, be::NUM3[1] => pkmn.level.to_s))
                pkmn.level_up_window_call(list[0],list[1],40005)
                if $scene.message_window
                  $scene.message_window.update while $game_temp.message_window_showing
                end
                pkmn.check_skill_and_learn
                #>Vérification évolution
                id, form = pkmn.evolve_check(:level_up)
                $scene.call_scene(::GamePlay::Evolve, pkmn, id, form, false) if(id)
              end
            end
            pkmn.loyalty += heal_data.loyalty if heal_data.loyalty
          end
        end
      end
      # If nothing has been fond and it's a special item
      if hash.empty? && (misc_data = item.misc_data)
        #> Item permettant de fuire
        if misc_data.flee
          hash[:action_to_push] = proc do
            be._mp([:end_flee])
          end
        #> Si c'est une baie qui modifie les EV
        elsif misc_data.berry && item_id >= 169 && item_id <= 174
          hash[:open_party] = true
          hash[:on_pokemon_choice] = proc do |pkmn|
            next(false) if(pkmn.loyalty >= 255 or pkmn.egg?)
            true
          end
          hash[:on_pokemon_use] = proc do |pkmn|
            pkmn.loyalty+=20
            pkmn.edit_bonus(misc_data.berry[:bonus])
          end
        #> Item permettant d'apprendre une attaque
        elsif (skill_id = misc_data.skill_learn) && skill_id != 0
          hash[:open_party] = true
          #> Choix dans l'interface (le système utilisera ça pour l'aptitude
          hash[:on_pokemon_choice] = proc do |pkmn|
            puts pkmn, pkmn.can_learn?(skill_id)
            next(false) if pkmn.egg?
            pkmn.can_learn?(skill_id)
          end
          hash[:open_skill_learn] = skill_id
        #> Item permettant d'appeler un évent
        elsif (event_id = misc_data.event_id) && event_id != 0
          hash[:use_before_telling] = CommonEventConditions[event_id] != nil
          hash[:on_use] = proc do
            if condition = CommonEventConditions[event_id] and condition.call
              $game_temp.common_event_id = misc_data.event_id
              $game_temp.in_battle ? $scene._close_bag : $scene.return_to_scene(Scene_Map)
            else
              $scene.display_message(parse_text(22, 43))
              next(:unused)
            end
          end
        #> Repousse
        elsif (repel_count = misc_data.repel_count) && repel_count != 0
          hash[:use_before_telling] = true
          hash[:on_use] = proc do
            if($pokemon_party.get_repel_count > 0)
              $scene.display_message(parse_text(22, 47))
              next(:unused)
            else
              $pokemon_party.set_repel_count(repel_count)
            end
          end
        #> Evolution par pierre
        elsif(misc_data.stone)
          hash[:open_party] = true
          hash[:on_pokemon_choice] = proc do |pkmn|
            next(false) if pkmn.egg?
            pkmn.evolve_check(:stone, item_id)
          end
          hash[:stone_evolve] = true
          hash[:on_pokemon_use] = proc do |pkmn|
            id, form = pkmn.evolve_check(:stone, item_id)
            _last_scene = $scene
            $scene.__result_process = proc do |scene|
              _last_scene.running = false
              $bag.add_item(item_id, 1) unless scene.evolved
            end
            #$scene.call_scene(::GamePlay::Evolve, pkmn, id, true)
            scene = ::GamePlay::Evolve.new(pkmn, id, form, true)
            scene.main
          end
        end
      end
      p hash
      return hash
    end
    # Add the bonus of a specific berry when used
    # @param imisc [GameData::ItemMisc] the data
    # @param pokemon [PFM::Pokemon] the Pokemon that receive the bonus
    def berry_check_bonus(imisc, pokemon)
      return unless imisc and pokemon
      if imisc.berry
        pokemon.edit_bonus(imisc.berry[:bonus])
      end
    end
  end
end
