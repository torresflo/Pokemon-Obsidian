module GamePlay
  class MiningGame
    private

    # Launch the procedure of clicking the tile and everything that ensue
    # @param x [Integer] the x coordinate of the clicked on tile
    # @param y [Integer] the y coordinate of the clicked on tile
    def tile_click(x, y)
      array = []
      array << @tiles_stack.get_tile(x, y)
      array.concat(@tiles_stack.get_adjacent_of(x, y))
      array.each_with_index do |tile, index|
        if @current_tool == :pickaxe
          reason = (index == 0 ? :pickaxe : :side_pickaxe)
        elsif @current_tool == :dynamite
          reason = (index == 0 ? :dynamite : :side_dynamite)
        else
          reason = :mace
        end
        tile.lower_state(reason)
      end
      @hit_counter_stack.send_hit(@current_tool)
      add_hit_to_stats
      diggables = []
      diggables << @handler.check_presence_of_diggable(x, y)
      diggables << @handler.check_presence_of_diggable(x - 1, y)
      diggables << @handler.check_presence_of_diggable(x + 1, y)
      diggables << @handler.check_presence_of_diggable(x, y - 1)
      diggables << @handler.check_presence_of_diggable(x, y + 1)
      reveal = @tiles_stack.get_tile(x, y).state == 0
      newly_revealed = false
      diggables.each do |diggable|
        if diggable.is_a? PFM::MiningGame::Diggable
          check = check_reveal_of_items(diggable)
          if check
            unless @arr_items_won.include? diggable
              @arr_items_won << diggable
              diggable.revealed = newly_revealed = true
            end
          end
        end
      end
      play_hit_animation(x, y, diggables[0], reveal, newly_revealed)
    end

    # Change the tool currently used
    # @param value [Integer] the value of the button pressed to change the tool
    def change_tool(value)
      case value
      when 0 then @current_tool = :pickaxe
      when 1 then @current_tool = :mace
      when 2 then @current_tool = :dynamite
      end
    end

    # Add one to the stat of the currently used item
    def add_hit_to_stats
      case @current_tool
      when :pickaxe
        PFM.game_state.mining_game.nb_pickaxe_hit += 1
      when :mace
        PFM.game_state.mining_game.nb_mace_hit += 1
      when :dynamite
        PFM.game_state.mining_game.nb_dynamite_hit += 1
      end
    end
  end
end
