#encoding: utf-8

#noyard
class Scene_Battle_Magneto < Scene_Battle
  def main
    @magneto = load_data("MagnetoVS.rxdata")
    @magneto.play
    super()
  end

  def setup_battle(type,actor_cnt,enemy_cnt,*battlers)
    $game_temp.vs_actors=1
    $game_temp.vs_enemies=1
    $game_temp.vs_type=type
    $game_temp.enemy_battler=[sprintf("%03d", 1+rand(182))]
    $game_temp.trainer_battle=true
    @actors = @magneto.party1
  end

  def configure_pokemons(*args)
    @enemy_party.actors = @magneto.party2
    @trainer_names = @magneto.names
    @seed = @magneto.get_action
    pc "Online seed: #{@seed}"
    srand(@seed)
    pc "Actors : #{$actors.join(" ")}\nEnemies : #{@enemy_party.actors.join(" ")}"
  end

  #===
  #>Phase principale
  #===
  def start_phase4
    @a_remaining_pk.visible = false
    @e_remaining_pk.visible = false if $game_temp.trainer_battle
    @phase = 4
    $game_temp.battle_turn += 1
    for index in 0...$data_troops[@troop_id].pages.size
      page = $data_troops[@troop_id].pages[index]
      if page.span == 1
        $game_temp.battle_event_flags[index] = false
      end
    end
    @enemy_actions.clear
    @actor_actions.clear
    #Test IA
    @seed = @magneto.get_action
    @actor_actions += @magneto.get_action
    @enemy_actions += @magneto.get_action
    pc "New seed : #{@seed}"
    srand(@seed)
    #>Sécurité
    BattleEngine::set_actors(@actors)
    BattleEngine::set_enemies(@enemies)
    @actions = BattleEngine::_make_action_order(@actor_actions, @enemy_actions, @actors, @enemies)
    @phase4_step = 0
    launch_phase_event(4,true)
  end

  #===
  #>Selection d'un Pokémon en fin de tour ou pour un switch (Actor)
  #===
  def phase4_actor_select_pkmn(i)
    return @magneto.get_action
  end
  alias phase4_enemie_select_pkmn phase4_actor_select_pkmn

  def start_phase2
    @phase = 2
    @counter = 40
  end

  def update_phase2
    @counter -= 1
    if(@counter <= 0)
      @to_start=:start_phase4
    end
  end

  def start_phase5
    return battle_end($game_switches[Yuki::Sw::BT_Defeat] ? 2 : 0)
  end

  def phase4_distribute_exp(i)

  end
end
