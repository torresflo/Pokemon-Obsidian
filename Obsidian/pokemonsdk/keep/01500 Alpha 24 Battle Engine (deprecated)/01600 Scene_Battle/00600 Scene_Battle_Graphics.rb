#encoding: utf-8

#noyard
# Description: Gestion des graphismes de combat
class Scene_Battle
  include UI
  #===
  #>Affichage du fond de combat
  #===
  def gr_display_background()
    @background = Sprite.new(@viewport)
    @background.z = 0
    @background.bitmap = RPG::Cache.battleback(Battle::Visual.allocate.send(:background_name))
  end

  #===
  #>Pré animation des Pokémon
  #===
  def gr_start_poke()
    animator = GamePlay::BattlePreWildAnimation.new(@viewport, @screenshot)
    @stuff_to_update << animator
    @message_window.visible = false
    Graphics.transition(1)
    Graphics.update while(animator.update) #> Démarrage de la séquence de combat
    @message_window.blocking = true #>Forcer l'appui pour passer les messages
    Audio.se_play(@enemies[0].cry)
    if($game_temp.vs_type == 1 or @enemies.size == 1)
      animation_shiny(animator.get_sprite(0), true) if @enemies[0].shiny
      display_message(parse_text(18,1, PKNAME[0] => @enemies[0].name))
    else
      Audio.se_play(@enemies[1].cry)
      animation_shiny(animator.get_sprite(0), true) if @enemies[0].shiny
      animation_shiny(animator.get_sprite(1), true) if @enemies[1].shiny
      display_message(parse_text(18,1, PKNAME[0] => @enemies[0].name)+"\n"+
      parse_text(18,1, PKNAME[0] => @enemies[1].name))
    end
    animator.unlock
    Graphics.update while(animator.update)
    gr_initialize_main_sprites
    animator.dispose
    @stuff_to_update.clear
  end

  #===
  #>Pré animation des dresseurs
  #===
  TrainerName_Format = "%s %s"
  Animators = [GamePlay::BattlePreTrainerAnimation, GamePlay::BattlePreTrainerAnimation5G]
  def gr_start_train()
    animator = Animators[$game_variables[Yuki::Var::TrainerTransitionType]]
    animator = Animators.first unless animator
    animator = animator.new(@viewport, @screenshot)
    @stuff_to_update << animator
    @message_window.visible = false
    Graphics.transition(1)
    Graphics.update while(animator.update) #>Déplacement du dresseur
    @message_window.blocking = true#true #>Forcer l'appui pour passer les messages
    #>Création du hub de ball adverse
    @e_remaining_pk = GamePlay::BattleBalls.new(@viewport, @enemies, true)
    @e_remaining_pk.z = 10
    @e_remaining_pk.y = -16
    @stuff_to_update << @e_remaining_pk
    @e_remaining_pk.move_to(320,0,30)
    first_name_0 = sprintf(TrainerName_Format, ::GameData::Trainer.class_name(@trainer_class),@trainer_names[0]) #> Formatage du nom des dresseurs pour la compréhension
    first_name_1 = sprintf(TrainerName_Format, ::GameData::Trainer.class_name(@trainer_class),@trainer_names[1]) #> Mod pour avoir le nom complet du dresseur à chaqu'une de ses actions.
    if($game_temp.vs_type == 1 or @enemies.size == 1)
      display_message(parse_text(18,9, BattleEngine::TRNAME[0] => first_name_0))
      animator.unlock
      @message_window.blocking = false
      display_message(parse_text(18,18, BattleEngine::TRNAME[0] => first_name_0,
      BattleEngine::PKNICK[1] => @enemies[0].given_name))
    else
      if @trainer_names.length == 1
        display_message(parse_text(18,9, BattleEngine::TRNAME[0] => first_name_0))
        animator.unlock
        @message_window.blocking = false
        display_message(parse_text(18,19, BattleEngine::TRNAME[0] => first_name_0,
        BattleEngine::PKNICK[1] => @enemies[0].given_name, BattleEngine::PKNICK[2] => @enemies[1].given_name))
        @trainer_names[1] = @trainer_names[0]
      else
        display_message(parse_text(18,11, BattleEngine::TRNAME[0] => first_name_0,
        BattleEngine::TRNAME[1] => first_name_1))
        animator.unlock
        @message_window.blocking = false
        #>A faire !
        if($game_temp.vs_enemies == 1)
          display_message(parse_text(18,18, BattleEngine::TRNAME[0] => first_name_0,
          BattleEngine::PKNICK[1] => @enemies[0].given_name))
          display_message(parse_text(18,18, BattleEngine::TRNAME[0] => first_name_1,
          BattleEngine::PKNICK[1] => @enemies[1].given_name))
        else

        end
      end
    end
    Graphics.update while(animator.update)
    animator.launch_balls
    animator.dispose
    @stuff_to_update.clear
    @stuff_to_update << @e_remaining_pk
    gr_initialize_main_sprites
  end

  #===
  #>Initialisation de l'affichage des sprites principaux
  #===
  def gr_initialize_main_sprites
    return if @actor_sprites.size > 0
    sprite = nil
    $game_temp.vs_type.times do |i|
      pk = @actors[i]
      pk.position = i if pk and !pk.dead?
      @actor_sprites << ::GamePlay::BattleSprite.new(@viewport, pk)
      sprite = @actor_sprites.last
      sprite.zoom_x = sprite.zoom_y = 0
      @actor_bars << ::GamePlay::BattleBar.new(@viewport, pk)
      @actor_bars.last.go_out(1).update
      pk = @enemies[i]
      if pk
        pk.position = -i - 1 
        @enemy_fought << pk
      end
      @enemy_sprites << ::GamePlay::BattleSprite.new(@viewport, pk)
      sprite = @enemy_sprites.last
      sprite.zoom_x = sprite.zoom_y = 0 if $game_temp.trainer_battle
      @enemy_bars << ::GamePlay::BattleBar.new(@viewport, pk)
      @enemy_bars.last.go_out(1).update if $game_temp.trainer_battle
    end
    @actors_ground = ::GamePlay::BattleGrounds.new(@viewport, true)
    @enemies_ground = ::GamePlay::BattleGrounds.new(@viewport, false)
    @a_remaining_pk = GamePlay::BattleBalls.new(@viewport, @actors, false)
    @a_remaining_pk.y = 176
    @a_remaining_pk.z = 50
    @viewport.sort_z
    Graphics.transition
    gr_enemy_launch_sequence
    gr_actor_launch_sequence if $game_variables[Yuki::Var::TrainerTransitionType] == 1
    30.times { update_animated_sprites ; Graphics.update }
    gr_actor_launch_sequence unless $game_variables[Yuki::Var::TrainerTransitionType] == 1
  end

  
  def gr_actor_launch_sequence
    $game_temp.vs_type.times do |i|
      pk = @actors[i]
      gr_launch_pokemon(pk) if pk and !pk.dead?
    end
  end

  def gr_enemy_launch_sequence
    tb = $game_temp.trainer_battle
    $game_temp.vs_type.times do |i|
      pk = @enemies[i]
      if tb
        gr_launch_pokemon(pk) if pk and !pk.dead?
      end
    end
  end

  #===
  #>Animation du KO
  #===
  def phase4_animation_KO(pokemon)
    $quests.beat_pokemon(pokemon.id) if pokemon.position < 0
    sp = gr_get_pokemon_sprite(pokemon)
    bar = gr_get_pokemon_bar(pokemon)
    bar.go_out(30)
    bar.refresh
    Audio.se_play("Audio/SE/Down.wav", 100, 80)
    while bar.moving
      bar.update
      sp.y += 4
      sp.opacity -= 13
      update_animated_sprites
      Graphics.update
    end
    sp.visible = false
    while(message = BattleEngine._message_check(:critical_hit, :efficient_msg, :unefficient_msg, :parametre))
      BattleEngine::BE_Interpreter.send(*message)
    end
    display_message(parse_text_with_pokemon(19, 0, pokemon, 
    BattleEngine::PKNICK[0] => pokemon.given_name))
    pokemon.status=0
    @_EXP_GIVE.push(pokemon)
    BattleEngine::_State_sub_update
    pokemon.reset_stat_stage
  end

  #===
  #> Animation de la cap spé
  #===
  def ability_display(pokemon)
    #display_message(parse_text(18,107,PFM::Text::PKNICK[0] => pokemon.given_name, PFM::Text::ABILITY[1] => pokemon.ability_name))
    GamePlay::BattleAbilityDisplayer.new(@viewport, pokemon, @stuff_to_update)
  end

  def gr_dispose()
    @actor_sprites.each do |i|
      i.dispose if i
    end
    @enemy_sprites.each do |i|
      i.dispose if i
    end
    @enemy_bars.each do |i|
      i.dispose if i
    end
    @actor_bars.each do |i|
      i.dispose if i
    end
    @to_dispose.each do |i|
      i.dispose
    end
    @background.dispose
    @a_remaining_pk.dispose if @a_remaining_pk
    @e_remaining_pk.dispose if @e_remaining_pk
    @actors_ground.dispose  if @actors_ground
    @enemies_ground .dispose if @enemies_ground
  end

  def gr_get_pokemon_sprite(pokemon)
    return (pokemon.position<0 ? @enemy_sprites[-pokemon.position-1] : @actor_sprites[pokemon.position])
  end

  def gr_get_pokemon_bar(pokemon)
    return (pokemon.position<0 ? @enemy_bars[-pokemon.position-1] : @actor_bars[pokemon.position])
  end

  def gr_callback_pokemon(pkm)
    sp = gr_get_pokemon_sprite(pkm)
    bar = gr_get_pokemon_bar(pkm)
    bar.go_out
    expulse = @_NoChoice[pkm] != nil
    zoom = expulse ? 0 : 0.10
    dx = expulse ? (pkm.position < 0 ? 10 : -10) : 0
    while bar.moving
      bar.update
      sp.zoom_x -= zoom
      sp.zoom_y = sp.zoom_x
      sp.x += dx
      update_animated_sprites
      Graphics.update
    end
    sp.visible = false
  end

  def gr_launch_pokemon(pkm)
    sp = gr_get_pokemon_sprite(pkm)
    bar = gr_get_pokemon_bar(pkm)
    bar.pokemon = pkm
    sp.pokemon = pkm
    bar.come_back
    #> Patch du launch qui zoom mal
    target_zoom = sp.zoom_x
    target_zoom = 1 if target_zoom == 0
    sp.zoom_y = sp.zoom_x = 0
    zoom = target_zoom/10.0 # 0.10
    Audio.se_play(pkm.cry)
    while bar.moving
      bar.update
      sp.zoom_y = (sp.zoom_x += zoom)
      update_animated_sprites
      Graphics.update
    end
    sp.zoom_y = sp.zoom_x = target_zoom
    animation_shiny(pkm) if pkm.shiny
  end

  
  def gr_show_trainer_e(t2=false)
    return if @phase!=5
    return unless $game_temp.trainer_battle

  end

  def gr_hide_trainer_e()
    return if @phase!=5
    return unless @t_e1

  end

end
