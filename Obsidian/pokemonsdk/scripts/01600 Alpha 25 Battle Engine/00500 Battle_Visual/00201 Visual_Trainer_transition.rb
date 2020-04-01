module Battle
  class Visual
    # Method that show the pre_transition of the battle
    def show_pre_transition
      # @type [Battle::Visual::RBJ_WildTransition]
      @transition = battle_transition.new(@battle_scene, @screenshot, @viewport)
      @animations << @transition
      @transition.pre_transition
      @locking = true
    end

    # Method that show the trainer transition of the battle
    def show_transition
      # Load transtion (x/y, dpp, frlg)
      # store the transition loop
      # Show the message "issuing a battle"
      # store the enemy ball animation
      # Show the message "send x & y"
      # store the actor ball animation
      # show the message "send x & y"
      @animations << @transition
      @transition.transition
      @locking = true
      @battle_scene.message_window.visible = true
    end

    # Function storing a battler sprite in the battler Hash
    # @param bank [Integer] bank where the battler should be
    # @param position [Integer, Symbol] Position of the battler
    # @param sprite [Sprite] battler sprite to set
    def store_battler_sprite(bank, position, sprite)
      @battlers[bank] ||= {}
      @battlers[bank][position] = sprite
    end

    # Retrieve the sprite of a battler
    # @param bank [Integer] bank where the battler should be
    # @param position [Integer, Symbol] Position of the battler
    # @return [BattleUI::PokemonSprite, nil] the Sprite of the battler if it has been stored
    def battler_sprite(bank, position)
      @battlers.dig(bank, position)
    end

    private

    # Return the current battle transition
    # @return [Class]
    def battle_transition
      collection = $game_temp.trainer_battle ? TRAINER_TRANSITIONS : WILD_TRANSITIONS
      transition_class = collection[$game_variables[Yuki::Var::Trainer_Battle_ID]]
      log_debug("Choosen transition class : #{transition_class}")
      return transition_class
    end

    # List of Wild Transitions
    # @return [Hash{ Integer => Class }]
    WILD_TRANSITIONS = {}

    # List of Trainer Transitions
    # @return [Hash{ Integer => Class }]
    TRAINER_TRANSITIONS = {}
  end
end
