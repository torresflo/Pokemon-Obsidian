#encoding: utf-8

#noyard
# Description: Définition de la phase de choix de l'ennemi à attaquer
class Scene_Battle
  include ::Util::TargetSelection
  #===
  #>update_phase3_enemy_select
  #Selection de l'ennemi
  #===
  def update_phase3_enemy_select
    pkmn = @actors[@actor_actions.size]
    skill = pkmn.skills_set[@atk_index]
    if skill.id == 174 and !pkmn.type_ghost? #> Malédiction
      return [pkmn]
    end
    #>Choix automatique en 1v1
    if $game_temp.vs_type == 1 or (@enemy_party.pokemon_alive==1 and $pokemon_party.pokemon_alive==1) or skill.is_no_choice_skill?
      return util_targetselection_automatic(pkmn, skill)
    #>Choix 2v2
    elsif $game_temp.vs_type == 2
      data = update_phase3_pokemon_select_2v2(pkmn, skill)
      return -1 if data == -1
      if data < 2
        return [@enemies[data]]
      end
      return [@actors[data-2]]
    else
      return -1
    end

  end

  #===
  #>Selection d'un Pokémon
  #===
  def update_phase3_pokemon_select_2v2(pkmn, skill)
    #> Si aucune cible on annule
    return -1 unless targets = util_targetselection_get_possible(pkmn, skill)
    selectables = Array.new(4,false)
    targets.each do |pkmn|
      if pkmn.position < 0
        selectables[-pkmn.position-1] = true
      else
        selectables[2+pkmn.position] = true
      end
    end
    update_phase3_enemy_select_window(*selectables)
    sps=@__p3ess
    ally_index=3-@actor_actions.size
    index=0
    index=1 if @enemies[0].dead?
    sps[1-index].opacity=sps[ally_index].opacity=128
    frames_count = 0
    loop do
      Graphics.update
      update_animated_sprites
      if(index<2 and Input.repeat?(:LEFT))
        sps[index].opacity=128
        index-=1
        index=1 if(index<0)
        sps[index].opacity=255
      elsif(index<2 and Input.repeat?(:RIGHT))
        sps[index].opacity=128
        index+=1
        index=0 if(index>1)
        sps[index].opacity=255
      elsif(Input.repeat?(:UP) or Input.repeat?(:DOWN))
        if(index<2)
          sps[index].opacity=128
          index=2
          sps[ally_index].opacity=255
        else
          index=ally_index-2
          sps[ally_index].opacity=128
          sps[index].opacity=255
        end
      elsif(Input.trigger?(:A) and (index == 2 ? selectables[ally_index] : selectables[index]))
        $game_system.se_play($data_system.decision_se)
        break
      elsif(Input.trigger?(:B))
        $game_system.se_play($data_system.cancel_se)
        index=-1
        break
      end
    end
    update_phase3_enemy_select_dispose
    return (index == 2 ? ally_index : index)
  end
  #===
  #>Procédure d'attente de validation 
  #===
  def update_phase3_enemy_select_validation(default_index=0)
    loop do
      Graphics.update
      update_animated_sprites
      if(Input.trigger?(:A))
        $game_system.se_play($data_system.decision_se)
        update_phase3_enemy_select_dispose
        return default_index
      elsif(Input.trigger?(:B))
        $game_system.se_play($data_system.cancel_se)
        update_phase3_enemy_select_dispose
        return -1
      end
    end
  end
  #===
  #>Génération de la fenêtre de choix
  #===
  def update_phase3_enemy_select_window(*selectables)
    rect = @viewport.rect
    wb = GameData::Windows::MessageHGSS
    width = (wb[4] + wb[-2] + 64)
    height = (wb[5] + wb[-1] + 64)
    window = UI::Window.new(@viewport,
      (rect.width - width) / 2, # x
      (rect.height - height) / 2, # y
      width, height, skin: 'm_4')
    window.z = 100000
    @__p3esw = window
    @__p3ess = Array.new(4) do |i|
      sprite = PokemonIconSprite.new(window, false)
              .set_position((i % 2 == 0 ? -4 : 28), (i / 2 == 0 ? -2 : 30))
      pokemon = (i / 2) == 0 ? @enemies[i] : @actors[i - 2]
      if pokemon && !pokemon.dead?
        sprite.data = pokemon
      else
        sprite.bitmap = RPG::Cache.b_icon('-01')
      end
      next sprite
    end
  end
  #===
  #>Suppression de la fenêtre de choix
  #===
  def update_phase3_enemy_select_dispose
    @__p3esw.dispose
    @__p3ess.each do |i|
      i.dispose
    end
    @__p3ess=nil
    @__p3esw=nil
  end
end
