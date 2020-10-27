module Battle
  class Logic
    private

    # Perform the attack action
    # @param action [Hash] action data
    def perform_action_attack(action)
      action[:skill].proceed(action[:launcher], action[:target_bank], action[:target_position])
    end

    # Perform the mega action (Mega-evolving)
    # @param action [Hash] action data
    def perform_action_mega(action)
      # TODO
    end

    # Perform the action of using an item
    # @param action [Hash] action data
    def perform_action_item(action)
      item_id = action[:item_id]
      bag = action[:bag]
      target = action[:target]
      process = PFM::ItemDescriptor.actions(item_id)
      # TODO call the action emulator
    end

    # Perform the action of switching
    # @param action [Hash] action data
    def perform_action_switch(action)
      # @type [PFM::PokemonBattler]
      who = action[:who]
      # @type [PFM::PokemonBattler]
      with = action[:with]
      visual = @battle_scene.visual
      # TODO call pre-switch processor
      # @type [BattleUI::PokemonSprite]
      (sprite = visual.battler_sprite(who.bank, who.position)).start_animation_going_in
      visual.hide_info_bar(who)
      until sprite.done?
        visual.update
        Graphics.update
      end
      # Logically switching the Pokemon
      switch_battlers(who, with)
      # Switching the sprite
      sprite.pokemon = with
      sprite.start_animation_going_out
      visual.show_info_bar(with)
      until sprite.done?
        visual.update
        Graphics.update
      end
      # TODO switch animation
      # TODO call post-switch processor
    end

    # Perform the action of fleeing (Roaming Pokemon)
    # @param action [Hash] action data
    def perform_action_flee(action)
      # TODO
    end
  end
end
