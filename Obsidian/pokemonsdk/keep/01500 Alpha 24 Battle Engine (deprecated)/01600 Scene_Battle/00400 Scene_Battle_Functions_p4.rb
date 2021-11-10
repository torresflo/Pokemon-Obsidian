#encoding: utf-8

#noyard
# Description: Définition de fonctions utiles ou d'animations pendant la phase 4
class Scene_Battle
  #===
  #>clean_effect
  #Mise à jour des effets d'une équipe de Pokémon
  #===
  def clean_effect(party)
    party.size.times do |i|
      party[i].battle_effect.update_counter(party[i]) unless party[i].dead?
    end
  end
  #===
  #>phase4_cant_display_message
  #Vérification de la possibilité d'affichage des message
  #===
  def phase4_cant_display_message(launcher,target)
    if launcher and launcher.hp<=0
      return true
    elsif target and target.hp<=0
      return true
    end
    return false
  end

  # HP Down animation
  # @param pokemon [PFM::Pokemon] Pokemon that loses the HP
  # @param hp [Integer] number of HP to remove
  def phase4_message_remove_hp(pokemon, hp)
    pk_hp = pokemon.hp
    max_time = (hp < 60 || pk_hp <= hp) ? 30 : 60
    1.step(max_time) do |i|
      pokemon.hp = pk_hp - (hp * i / max_time)
      status_bar_update(pokemon)
      break if pokemon.hp <= 0
      Graphics.update
      update_animated_sprites
    end
    phase4_animation_KO(pokemon) if (pk_hp - hp) <= 0
  end

  # HP Up animation
  # @param pokemon [PFM::Pokemon] Pokemon that receive the HP
  # @param hp [Integer] number of HP to add
  def phase4_message_add_hp(pokemon, hp)
    pk_hp = pokemon.hp
    max_time = hp < 60 ? 30 : 60
    1.step(max_time) do |i|
      pokemon.hp = pk_hp + (hp * i / max_time)
      status_bar_update(pokemon)
      break if pokemon.hp == pokemon.max_hp
      Graphics.update
      update_animated_sprites
    end
  end
  #===
  #>status_bar_update
  #Mise à jour de la status bar d'un Pokémon
  #===
  def status_bar_update(pokemon)
    return unless pokemon.position

    if pokemon.position.to_i<0
      bar=@enemy_bars[-pokemon.position-1]
    else
      bar=@actor_bars[pokemon.position]
    end
    return unless bar
    bar.refresh
    bar.update
  end

  # Distribute the exp for the enemies of pokemon
  # @param pokemon [PFM::Pokemon] the pokemon that got KO'd
  def phase4_distribute_exp(pokemon)
    return if $game_switches[::Yuki::Sw::BT_NoExp]
    # Pokemon getting the exp
    # @type [Array<PFM::Pokemon>]
    getters = (pokemon.position < 0 ? @actors : @enemies)
    # Calculate the total amount of turn
    turn_sum = getters.reject(&:dead?).sum { |battler| battler&.battle_turns || 0 }
    return if turn_sum == 0 # No exp if no turn used to beat the enemy
    # Number of turn used by the current battling pokemon
    battle_turn = getters[0, $game_temp.vs_type].reject(&:dead?).sum { |battler| battler&.battle_turns || 0 }
    # We try to give exp to each pokemon
    getters.each_with_index do |battler, index|
      # No exp if KO or level >= max_level
      next if !battler || battler.dead?
      next if battler.level >= $pokemon_party.level_max_limit
      # Calculate the amount of exp according to if the pokemon is battling or not
      base_exp = phase4_exp_calculation(pokemon, battler)
      if index < $game_temp.vs_type
        exp_amount = base_exp * battle_turn / turn_sum / $game_temp.vs_type
      else
        exp_amount = base_exp * battler.battle_turns / turn_sum
      end

      # Bonus from Multi-Exp
      exp_amount += (base_exp / 2) if battler.item_db_symbol == :"exp._share" && index >= $game_temp.vs_type

      # No distribution if no exp
      next if exp_amount == 0

      # EV distribution
      battler.add_bonus(pokemon.battle_list)

      # Exp animation
      phase4_distribute_exp_animation(battler, exp_amount, index)
    end
    @exp_distributed = true
  end

  EXP_SOUND = 'audio/se/exp_sound'
  LVL_SOUND = 'audio/me/rosa_levelup'
  # Animation of the experience distribution to one Pokemon
  # @param battler [PFM::Pokemon] Pokemon receiving the exp
  # @param exp_amount [Integer] number of exp point to distribute
  # @param index [Integer] index of the battler in the battler array
  def phase4_distribute_exp_animation(battler, exp_amount, index)
    # Display exp message
    text = parse_text(
      18, battler.item_db_symbol == :"exp._share" ? 44 : 43,
      '[VAR 010C(0000)]' => battler.given_name,
      NUM7R => exp_amount.to_s
    )
    display_message(text)
    final_exp = battler.exp + exp_amount
    play_animation = index < $game_temp.vs_type && battler.position
    # Distribution loop
    while battler.exp < final_exp && battler.level < $pokemon_party.level_max_limit
      exp_delta = (battler.exp_lvl - battler.exp_list[battler.level]) / 104
      exp_delta = 1 if exp_delta <= 0
      Audio.se_play(EXP_SOUND) if play_animation
      # Current level exp distribution
      while battler.exp < final_exp && battler.exp < battler.exp_lvl
        # Add & calibration
        battler.exp = (battler.exp + exp_delta).clamp(0, battler.exp_lvl).clamp(0, final_exp)
        # Show bar animation
        next unless play_animation
        status_bar_update(battler)
        Graphics.update
        update_animated_sprites
      end
      Audio.se_stop
      # Level up sequenc if needed
      if battler.exp >= battler.exp_lvl
        list = battler.level_up_stat_refresh
        status_bar_update(battler) if play_animation
        Audio.me_play(LVL_SOUND)
        PFM::Text.set_num3(battler.level.to_s, 1)
        display_message(parse_text(18, 62, '[VAR 010C(0000)]' => battler.given_name))
        PFM::Text.reset_variables
        battler.level_up_window_call(list[0], list[1], @message_window.z + 5) if @actors.include?(battler) # battler.position >= 0
        @message_window.update
        Graphics.update
        update_animated_sprites
        battler.check_skill_and_learn
        @_Evolve << battler unless @_Evolve.include?(battler)
      end
    end
  end

  #===
  #>phase4_exp_calculation
  #Calcul de l'expérience
  #===
  def phase4_exp_calculation(killed,receiver)
    #> Oeuf chance (+50%)
    return (killed.base_exp*killed.level*3/14) if(receiver.battle_item == 231)
    return killed.base_exp*killed.level/7
  end
  #===
  #>phase4_actor_select_pkmn
  # Selection d'un Pokémon pour l'actor
  #===
  def phase4_actor_select_pkmn(i,forced=true)
    egg_party = []
    @actors.each { |j| egg_party << j unless BattleEngine.get_ally!(i).include?(j) }
    egg_check = egg_party.all?(&:dead?)
    return false if egg_check
    
    @message_window.visible = false
    $scene = scene = GamePlay::Party_Menu.new(@actors, :battle, no_leave: forced)
    scene.main#(true)
    @message_window.visible = true
    $scene = self
    return_data = scene.return_data
    Graphics.transition
    return false if return_data == -1
    return [2,return_data,i.position]
  end
  #===
  #>phase4_enemie_select_pkmn
  #Vérification de la possibilité d'envoyer un autre ennemi
  #===
  def phase4_enemie_select_pkmn(i)
    #>Temporaire en attendant la reprogrammation de l'IA
=begin
    $game_temp.vs_type.step(@enemies.length-1) do |j|
      if @enemies[j] and !@enemies[j].dead?
        return [2,-j-1,-i.position-1]
      end
    end
=end
    return PFM::IA.request_switch(i)
    #$game_temp.vs_type.step(@enemies.length-1) do |j|
    #  if @enemies[j] and !@enemies[j].dead?
    #    return j
    #  end
    #end
    return false
=begin
    if @enemies[i].dead?
      $game_temp.vs_type.step(@enemies.length-1) do |j|
        if @enemies[j] and !@enemies[j].dead?
          return j
          tmp=@enemies[j]
          @enemies[j]=@enemies[i]
          @enemies[i]=tmp
          return true
        end
      end
      return false
    end
    return false
=end
  end
  #===
  #>phase4_try_to_catch_pokemon
  #Fonction de tentative de capture d'un Pokémon
  #===
  ULTRA_BEAST = [789,790,791,792,793,794,795,796,797,798,799,800,803,804,805,806] # ID des Ultra-Chimères
  MOON_EVOLVE = [29,30,31,32,33,34,35,36,39,40,173,174,300,301,517,518] # ID des lignés des Pokémons qui évoluent avec une Pierre Lune
  def phase4_try_to_catch_pokemon(ball_data,id)
    pokemon=@enemies[@enemies[0].dead? ? 1 : 0]
    hpmax=pokemon.max_hp*3
    hp=pokemon.hp*2
    rate=pokemon.rareness
    #Calcul du bonus de status
    case pokemon.status
    when 1,2,3,8
      bs=1.5
    when 4,5
      bs=2.5 #Depuis la 5G, c'est passé à x2.5
    else
      bs=1
    end
    #Calcul du bonus de ball utilisé
    bb=phase4_ball_bonus(ball_data,pokemon)
    puts "Bonus Ball : #{bb}"
    #>Masse ball (avec patch USUL)
    if(ball_data.special_catch and ball_data.special_catch[:mass] and rate > 0)
      if(pokemon.weight < 100 and rate >= 21)
        rate -= 20
      elsif(pokemon.weight < 100 and rate < 21)
        rate = 1
      elsif(pokemon.weight > 300)
        rate += 30
      elsif(pokemon.weight > 200)
        rate += 20
      end
    end
    #Taux préliminaires
    a=(hpmax-hp)*rate*bs*bb/hpmax
    b=(0xFFFF*(a/255.0)**0.25).to_i
    if rate == 0 or $game_switches[Yuki::Sw::BT_NoCatch] or $game_temp.trainer_battle == true # Capture impossible ou interdite
      cnt=-2
    else
      cnt=0
      4.times do |i|
        cnt+=1 if(rand(0xFFFF)<b)
      end
    end
    return phase4_animation_capture(cnt,pokemon,id)
  end
  #===
  #>phase4_ball_bonus
  #Calcule le bonus conféré par la balle
  #===
  def phase4_ball_bonus(ball_data,pokemon)
    data=ball_data.special_catch
    if(data)
      if(types=data[:types]) and !ULTRA_BEAST.include?(pokemon.id) # Si Ultra Chimère, on skip cette condition
        if(types.include?(pokemon.type1) or types.include?(pokemon.type2))
          return (data[:catch_rate] ? data[:catch_rate] : ball_data.catch_rate)
        end
      elsif ULTRA_BEAST.include?(pokemon.id) # Si Ultra-Chimère
        if (data[:ub_ball]) # Ultra Ball à paramétrer avec la capture spécifique (hash) : "{ub_ball: true}" dans le Ruby Host (ID de la ball dans le Ruby Host : 851)
          return 5      
        else
          return 0.1      
        end
      elsif (data[:ub_ball]) # Ultra Ball lancée sur une non Ultra-Chimère
        return 0.1
      elsif(data[:level]) #Faiblo ball
        if(pokemon.level<19)
          return 3
        elsif pokemon.level<29
          return 2
        end
      elsif(data[:time]) #Chrono ball
        return [(0.7+$game_temp.battle_turn*0.3),4].min
      elsif(data[:bis]) #Bis ball
        return 3 if $pokedex.has_captured?(pokemon.id)
      elsif(data[:scuba]) #Scuba ball
        return 3.5 if $env.under_water? or $env.pond? or $env.sea? or @fished #Vérifier si on est sur l'eau, sous l'eau ou en train de pêcher
      elsif(data[:dark]) #Sombre ball
        return 3 if $env.night? or $env.cave?#Vérifier si on est la nuit ou dans une grotte
      elsif(data[:speed]) #Rapide Ball
        return 5 if $game_temp.battle_turn<2
        return 1 if $game_temp.battle_turn>=2
      elsif(data[:speed_pk])
        return 4 if pokemon.base_spd >= 100 or $wild_battle.is_roaming?(pokemon)#>Vérifier que le pokémon adverse est rapide
      elsif(data[:appat])
        return 5 if @fished #>Vérifier que le pokémon vient d'être peché
      elsif(data[:level_ball])
        lvl = @actors[0].level
        if(lvl / 4 > pokemon.level)
          return 8
        elsif(lvl / 2 > pokemon.level)
          return 4
        elsif(lvl > pokemon.level)
          return 2
        end
      elsif(data[:moon_ball])
        return 4 if MOON_EVOLVE.include?(pokemon.id)
      elsif(data[:love])
        if(@actors[0].gender * pokemon.gender == 2) and @actors[0].id == pokemon.id
          return 8
        end
      end
      return 1
    elsif ULTRA_BEAST.include?(pokemon.id) and ball_data.catch_rate < 255 # Traitement des balls sans data, on exclut le malus d'Ultra-Chimère sur la Master ball
      return 0.1 # Ball sans "data" lancée sur Ultra Chimère. (L'Ultra Ball a de la data et a donc déjà été traitée en amont)
    else
      return ball_data.catch_rate
    end
  end
  #===
  #>phase4_animation_capture
  #Animation de la capture //!!!\\ A terminer !
  #===
  def phase4_animation_capture(cnt,pokemon,id)
    case cnt
    when -2
      gr_deflect_ball(pokemon, id)
    when 3,4
      gr_launch_ball_to_enemy(pokemon, id)
      shake=3
    when 2
      gr_launch_ball_to_enemy(pokemon, id)
      shake=2
    when 1
      gr_launch_ball_to_enemy(pokemon, id)
      shake=1
    else
      gr_launch_ball_to_enemy(pokemon, id)
      shake=0
    end
    if cnt >= 0
      shake.times do # Détermine nombre de secousses
        gr_animate_ball_on_enemy(pokemon)
      end
    end

    if cnt >= 4
      gr_animate_caught(pokemon)
      #Faire toute la scène de capture
      $game_switches[Yuki::Sw::BT_Catch] = true
      pokemon.captured_with = id
      pokemon.captured_at = Time.new.to_i
      pokemon.trainer_name = $trainer.name
      pokemon.trainer_id = $trainer.id
      @_EXP_GIVE.push(pokemon)  # ligne ajoutée pour donner l'XP à la capture.
      pokemon.reset_stat_stage
      start_phase5
    else
      case cnt
      when -2
        $bag.add_item(id, 1) #Le joueur récupère la ball déviée
        if $game_temp.trainer_battle
          display_message(parse_text(18, 69)) # Pokémon d'un dresseur, ball déviée
        else
          display_message(parse_text(20, 84)) # Capture impossible, ball déviée. Le message "chen" est le moins pire parmi les strings disponibles pour notifier cet impossibilité.
        end
      when 3
        gr_animate_pokebreak(pokemon)
        display_message(parse_text(18, 66))
      when 2
        gr_animate_pokebreak(pokemon)
        display_message(parse_text(18, 65))
      when 1
        gr_animate_pokebreak(pokemon)
        display_message(parse_text(18, 64))
      else
        gr_animate_pokebreak(pokemon)
        display_message(parse_text(18, 63))
      end
    end
  end

  # Show the launch ball animation
  # @param pokemon [PFM::Pokemon] Pokemon we try to catch
  # @param id [Integer] ID of the ball in the database
  def gr_launch_ball_to_enemy(pokemon, id)
    pokemon_sprite = gr_get_pokemon_sprite(pokemon)
    origin_sprite = pokemon.position < 0 ? @actor_sprites.first : @enemy_sprites.first
    @ball_sprite = Sprite.new(@viewport).set_bitmap(GameData::Item[id].ball_data.img, :ball)
    @ball_sprite.visible = false
    @animator = Yuki::Basic_Animator.new(load_data('Data/Animations/pokeball_catch.dat'), origin_sprite, pokemon_sprite)
    @animator.parameters[:ball_sprite] = @ball_sprite
    while @animator.update
      update_animated_sprites
      Graphics.update unless @animator.terminated?
    end
    @animator = nil
  end

  # --- Ajout - animation créée à l'origine pour Sacred Phoenix ---
  # Show the deflect ball animation
  # @param pokemon [PFM::Pokemon] Pokemon we try to catch
  # @param id [Integer] ID of the ball in the database
  def gr_deflect_ball(pokemon, id)
    pokemon_sprite = gr_get_pokemon_sprite(pokemon)
    origin_sprite = pokemon.position < 0 ? @actor_sprites.first : @enemy_sprites.first
    @ball_sprite = Sprite.new(@viewport).set_bitmap(GameData::Item[id].ball_data.img, :ball)
    @ball_sprite.visible = false
    @animator = Yuki::Basic_Animator.new(load_data('Data/Animations/pokeball_deflect.dat'), origin_sprite, pokemon_sprite)
    @animator.parameters[:ball_sprite] = @ball_sprite
    while @animator.update
      update_animated_sprites
      Graphics.update unless @animator.terminated?
    end
    @animator = nil
  end

  # Show the moving animation of the ball
  # @param pokemon [PFM::Pokemon] Pokemon we try to catch
  def gr_animate_ball_on_enemy(pokemon)
    pokemon_sprite = gr_get_pokemon_sprite(pokemon)
    origin_sprite = pokemon.position < 0 ? @actor_sprites.first : @enemy_sprites.first
    @animator = Yuki::Basic_Animator.new(load_data('Data/Animations/pokeball_move.dat'), origin_sprite, pokemon_sprite)
    @animator.parameters[:ball_sprite] = @ball_sprite
    while @animator.update
      update_animated_sprites
      Graphics.update unless @animator.terminated?
    end
    #@ball_sprite.dispose
    @animator = nil
  end

  # Show the catch animation of the ball
  # @param pokemon [PFM::Pokemon] Pokemon we try to catch
  def gr_animate_caught(pokemon)
    pokemon_sprite = gr_get_pokemon_sprite(pokemon)
    origin_sprite = pokemon.position < 0 ? @actor_sprites.first : @enemy_sprites.first
    @animator = Yuki::Basic_Animator.new(load_data('Data/Animations/pokeball_got.dat'), origin_sprite, pokemon_sprite)
    @animator.parameters[:ball_sprite] = @ball_sprite
    while @animator.update
      update_animated_sprites
      Graphics.update unless @animator.terminated?
    end
    @animator = nil
  end

  # Show the break animation of the ball
  # @param pokemon [PFM::Pokemon] Pokemon we try to catch
  def gr_animate_pokebreak(pokemon)
    pokemon_sprite = gr_get_pokemon_sprite(pokemon)
    origin_sprite = pokemon.position < 0 ? @actor_sprites.first : @enemy_sprites.first
    @animator = Yuki::Basic_Animator.new(load_data('Data/Animations/pokeball_break.dat'), origin_sprite, pokemon_sprite)
    @animator.parameters[:ball_sprite] = @ball_sprite
    while @animator.update
      update_animated_sprites
      Graphics.update unless @animator.terminated?
    end
    @ball_sprite.dispose
    @animator = nil
  end

  #===
  #>_phase4_status_check
  #Traitement des effets des status
  #===
  def _phase4_status_check(pkmn)
    return if(!pkmn or pkmn.dead? or BattleEngine::Abilities.has_ability_usable(pkmn,17)) #>Garde Magik
    if(pkmn.poisoned?) #Poison
      #>Soin Poison
      if(BattleEngine::Abilities::has_ability_usable(pkmn,89))
        BattleEngine::_msgp(19, 387, pkmn)
        BattleEngine::_message_stack_push([:hp_up, pkmn, pkmn.poison_effect])
      else
        BattleEngine::_msgp(19, 243, pkmn)
        BattleEngine::_mp([:animation_on, pkmn, 469 + pkmn.status])
        BattleEngine::_message_stack_push([:hp_down_proto, pkmn, pkmn.poison_effect])
      end
    elsif(pkmn.burn?) #Brûlure
      hp = pkmn.burn_effect
      hp /= 2 if BattleEngine::Abilities::has_ability_usable(pkmn, 117) #> Ignifugé
      BattleEngine::_msgp(19, 261, pkmn)
      BattleEngine::_mp([:animation_on, pkmn, 469 + pkmn.status])
      BattleEngine::_message_stack_push([:hp_down,pkmn,pkmn.burn_effect])
    elsif(pkmn.toxic?) #Intoxiqué
      BattleEngine::_msgp(19, 243, pkmn)
      BattleEngine::_mp([:animation_on, pkmn, 469 + pkmn.status])
      BattleEngine::_message_stack_push([:hp_down_proto,pkmn,pkmn.toxic_effect])
    end
  end
  #===
  #>switch_pokemon
  # Fonction permettant de réaliser un switch
  #===
  def switch_pokemon(from, to = nil)
    unless @_SWITCH.include?(from)
     @_SWITCH.push(from)
      if(to)
        @_NoChoice[from] = to
      end
    end
  end

  # Function that ask if the trainer wants to switch
  def phase4_switch_question(new_enemy)
    if $options.battle_mode && (@actors.count { |act| act&.alive? } > 1)
      text = parse_text(
        18, 21,
        '[VAR 010E(0000)]' => GameData::Trainer.class_name(@trainer_class),
        '[VAR TRNAME(0001)]' => @trainer_names[0],
        '[VAR 019E(0000)]' => "#{GameData::Trainer.class_name(@trainer_class)} #{@trainer_names[0]}",
        '[VAR PKNICK(0002)]' => (@enemies[-new_enemy[1] - 1])&.given_name.to_s
      )
      choice = display_message(text, true, 1, text_get(11, 27), text_get(11, 28))
      if choice == 0
        result = phase4_actor_select_pkmn(@actors[0],false)
        phase4_switch_pokemon(result) if result
      end
    end
  end
  #===
  #>_phase4_switch_check
  # Vérification des switchs à réaliser
  #===
  def _phase4_switch_check
    return @_SWITCH.clear if judge
    to_del = [] #Array des Pokémon à supprimer du tableau de switch
    turn = @phase4_step<@actions.size #>Si on est pas à la fin du tour
    #Affichage des switch A REMANIER !!!!
    @_SWITCH.each do |i|
      next unless i
      next if i.dead? and turn #>Empêcher switch mort avant la fin
      to_del << i
      #>Choix forcé
      if(to = @_NoChoice[i])
        if(i.position < 0)
          phase4_switch_pokemon([2,-@enemies.index(to).to_i-1, -i.position-1])
        else
          phase4_switch_pokemon([2,@actors.index(to).to_i, i.position])
        end
        @_NoChoice.delete(i)
        next
      end
      #>Choix libre
      if i.position<0
        new_enemy=phase4_enemie_select_pkmn(i)
        #phase4_switch_pokemon([2,-new_enemy-1,-i.position-1]) if new_enemy
        if new_enemy
          phase4_switch_question(new_enemy) if $game_temp.vs_type == 1 && @actors[0].hp > 0
          phase4_switch_pokemon(new_enemy)
        end
        @e_remaining_pk.redraw if $game_temp.trainer_battle
      else
        #Vérification de la possibilité de switch
        if($game_temp.vs_type==2)
          alive=0
          @actors.each do |j|
            alive+=1 if j and j.hp>0
          end
          next if(alive<2)
        end
        #Tentative de fuite en 1v1 wild
        unless($game_temp.trainer_battle or $game_temp.vs_type==2 or $game_switches[Yuki::Sw::BT_NoEscape])
          #r=display_message("Voulez-vous envoyer un autre Pokémon ?\n",false,1,"Oui","Non")
          r=display_message(text_get(18, 80),true,1,text_get(20, 56),text_get(20, 55))
          if(r == 1)
            if(update_phase2_escape(true))
              $game_system.se_play($data_system.escape_se)
              return battle_end(1)
            else
              display_message(text_get(18, 77)) #"Impossible de fuire.")
            end
          end
        end
        #Switch si possible
        new_actor=phase4_actor_select_pkmn(i)
        phase4_switch_pokemon(new_actor) if new_actor
        @a_remaining_pk.redraw
      end
    end
    #suppression
    to_del.each do |i|
      @_SWITCH.delete(i)
    end
  end
end
