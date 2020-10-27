#encoding: utf-8

#noyard
module GamePlay
  class StorageMove < Base
    MOV = "Déplacer"
    INF = "Résumé"
    REL = "Relâcher"
    QTT = "Quitter"
    def initialize
      super()
      @utils = StorageUtils.new
      @index = 1
      @pokemon_move = nil
      @utils.draw_selector(@index)
      @running = true
    end

    def create_graphics
      # Skipped to prevent glitches
    end

    def update
      @utils.update
      return if $game_temp.message_text
      if (Input.trigger?(:B) && @pokemon_move == nil && @utils.check)
        c = @utils.display_message(text_get(33, 85), 2, text_get(33, 83), text_get(33, 84))
        @running = false if (c == 1)
      end
      if (@index == 0) # Changement de boîte
        @index = @utils.changer_boite(@index, @pokemon_move)
      elsif (@index > 0 and @index < 31)# Déplacement dans la boîte
        @index = @utils.deplacement_boite(@index, :move, @pokemon_move)
        if (Input.trigger?(:A))
          if (@mode == :move)
            if ($storage.slot_contain_pokemon?(@index - 1)) # Pokémon présent
              pokemon = $storage.remove_pokemon_at(@index - 1)
              $storage.store_pokemon_at(@pokemon_move, @index - 1)
              @pokemon_move = pokemon
              @utils.change_box
              @utils.draw_selector(@index, @pokemon_move)
            else
              $storage.store_pokemon_at(@pokemon_move, @index - 1)
              @pokemon_move = nil
              @utils.change_box
              @utils.draw_selector(@index)
              @mode = :selection
            end
          else
            return if (!$storage.slot_contain_pokemon?(@index - 1))
            choice
          end
        end
      else # Déplacement dans l'équipe
        @index = @utils.deplacement_equipe(@index, :move, @pokemon_move)
        if (Input.trigger?(:A))
          if (@mode == :move)
            if ($actors[@index - 31] != nil) # Pokémon présent
              pokemon = $actors[@index - 31].clone
              $actors[@index - 31] = @pokemon_move
              @pokemon_move = pokemon
              @utils.draw_pokemon_team
              @utils.draw_selector(@index, @pokemon_move)
            else
              $actors.push(@pokemon_move)
              $actors.compact!
              @pokemon_move = nil
              @utils.draw_pokemon_team
              @utils.draw_selector(@index)
              @mode = :selection
            end
          else
            return if ($actors[@index - 31] == nil)
            choice
          end
        end
      end
    end

    def choice
      arr = Array.new
      arr.push(text_get(33, 39), text_get(33, 41), text_get(33, 81), text_get(33, 82))
      ind = @utils._party_window(*arr)
      if (ind == 0)
        move_pokemon
      elsif (ind == 1)
        @utils.sumary_pokemon(@index)
      elsif (ind == 2)
        @utils.release_pokemon(@index)
      end
    end

    def move_pokemon
      if (@index >= 31) # Équipe Pokémon
        @pokemon_move = $actors[@index - 31]
        $actors[@index - 31] = nil
        return cancel_drop if (!@utils.check)
        $actors.compact!
        @utils.draw_pokemon_team
      else # Boîte
        @pokemon_move = $storage.remove_pokemon_at(@index - 1)
        @utils.draw_init
      end
      @utils.draw_selector(@index, @pokemon_move)
      @mode = :move
    end

    def cancel_drop
      if (@mode == :move)
        $actors.push(@pokemon_move)
        @index = 30 + $actors.size
        @index = 31 if @index < 31
      else
        $actors.size.times do |i|
          if ($actors[i] == nil)
            $actors[i] = @pokemon_move.clone
            break
          end
        end
      end
      @pokemon_move = nil
      @utils.draw_pokemon_team
      @utils.draw_selector(@index)
      @mode = :selection
    end

    def dispose
      @utils.dispose
    end
  end
end
