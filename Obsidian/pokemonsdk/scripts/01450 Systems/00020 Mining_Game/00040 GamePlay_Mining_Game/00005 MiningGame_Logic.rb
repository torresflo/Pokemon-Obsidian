module GamePlay
  class MiningGame
    private

    # Dull method, only here to check the win condition
    # @return [Boolean] false if @running == false
    def update_inputs
      return false if @transition_animation && !@transition_animation.done?
      return false if @running == false

      check_win_lose_condition if @ui_state != :animation
      return true
    end

    # Check if a diggable item has been revealed
    # @param item [PFM::MiningGame::Diggable]
    # @return [Boolean]
    def check_reveal_of_items(item)
      return true if item.revealed

      return item.pattern.each_with_index.all? do |line, index_y|
        next line.each_with_index.all? do |square, index_x|
          check = !square
          check = @tiles_stack.get_tile(item.x + index_x, item.y + index_y).state == 0 unless check
          next check
        end
      end
    end

    # Method that play the text displayed for the first time the player plays
    def first_time_text
      FIRST_TIME_TEXT.size.times do |i|
        if i == 2
          str = $pokemon_party.mining_game.dynamite_unlocked ? FIRST_TIME_TEXT_ALTERNATIVE : FIRST_TIME_TEXT[i]
          display_message(ext_text(*str))
        else
          display_message(ext_text(*FIRST_TIME_TEXT[i]))
        end
      end
      $pokemon_party.mining_game.first_time = false
    end

    # ID of the ping text
    PING_TEXT = [9005, 4]
    # Method that play the ping text
    def ping_text
      PFM::Text.set_variable('[NB_ITEM]', @handler.arr_items.size.to_s)
      display_message(ext_text(*PING_TEXT))
      PFM::Text.reset_variables
    end

    # Check if the game is won or lost, and if none of the two then return
    def check_win_lose_condition
      if @arr_items_won.size == @handler.arr_items.size
        win
        end_of_game
      elsif @hit_counter_stack.max_cracks?
        lose
      end
    end

    # ID of the text for the lose scenario
    LOSE_TEXT = [9005, 13]
    # Method that play the lose condition
    def lose
      $pokemon_party.mining_game.nb_game_failed += 1
      Audio.se_play(File.join(SE_PATH, 'collapse'))
      start_wall_collapse_anim
    end

    # Show the message starting lost
    def launch_loose_message
      display_message_and_wait(ext_text(*LOSE_TEXT))
      end_of_game
    end

    # ID of the text for the win scenario
    WIN_TEXT = [9005, 14]
    # Method that play the win condition
    def win
      $pokemon_party.mining_game.nb_game_success += 1
      Audio.se_play(File.join(SE_PATH, 'win'))
      display_message(ext_text(*WIN_TEXT))
    end

    # ID of the text used to tell what items were excavated
    ITEM_WON_TEXT = [9005, 15]
    # Method that end the game and exit the scene
    def end_of_game
      @arr_items_won.each do |item|
        PFM::Text.set_variable('[NAME_ITEM]', GameData::Item[item.symbol].name)
        Audio.me_play('audio/me/ROSA_ItemObtained')
        display_message_and_wait(ext_text(*ITEM_WON_TEXT))
        $pokemon_party.bag.add_item(item.symbol)
      end
      $pokemon_party.mining_game.nb_items_dug += @arr_items_won.size
      @running = false
    end
  end
end
