module PFM
  # List of Processes that are called when a skill is used in map
  # Associate a skill id to a proc that take 3 parameter : pkmn(PFM::Pokemon), skill(PFM::Skill), test(Boolean)
  SKILL_PROCESS = {
    milk_drink: milk_drink = proc do |pkmn, _skill, test = false|
      next :block if pkmn.hp <= 0 && test
      next :choice if test
      if $actors[$scene.return_data] != pkmn && !pkmn.dead? && pkmn.hp != pkmn.max_hp
        # Put heal animation here
        heal_hp = pkmn.max_hp * 20 / 100
        $actors[$scene.return_data].hp -= heal_hp
        pkmn.hp += heal_hp
      else
        $scene.display_message(parse_text(22, 108))
      end
    end,
    soft_boiled: milk_drink,
    sweet_scent: proc do |_pkmn, _skill, test = false|
      next false if test
      if $env.normal?
        if $wild_battle.available?
          $game_system.map_interpreter.launch_common_event(Game_CommonEvent::WILD_BATTLE)
        else
          $scene.display_message(parse_text(39, 7))
        end
      else
        $scene.display_message(parse_text(39, 8))
      end
    end,
    fly: proc do |pkmn, _skill, test = false|
      next false if test

      if $game_switches[Yuki::Sw::Env_CanFly]
        GamePlay.open_town_map_to_fly($env.get_worldmap, pkmn)
        next true
      else
        next :block
      end
    end,
    surf: proc do |_pkmn, _skill, test = false|
      d = $game_player.direction
      x = $game_player.x
      y = $game_player.y
      z = $game_player.z
      new_x, new_y = $game_player.front_tile
      sys_tag = $game_map.system_tag(new_x, new_y)
      next :block unless $game_map.passable?(x, y, d, nil) &&
                         $game_map.passable?(new_x, new_y, 10 - d, $game_player) &&
                         z <= 1 && !$game_player.surfing? &&
                         Game_Character::SurfTag.include?(sys_tag)
      next false if test
      $game_temp.common_event_id = Game_CommonEvent::SURF_ENTER
      next true
    end
  }
end
