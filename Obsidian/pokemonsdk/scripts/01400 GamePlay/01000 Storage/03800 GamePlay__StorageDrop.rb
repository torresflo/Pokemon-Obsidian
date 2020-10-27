#encoding: utf-8

#noyard
module GamePlay
  class StorageDrop < Base
    DEP = "Déposer"
    INF = "Résumé"
    REL = "Relâcher"
    QTT = "Quitter"
    def initialize
      super()
      @utils = StorageUtils.new
      @index = 31
      @mode = :selection
      @pokemon_drop = nil
      @utils.draw_selector(@index)
      @running = true
    end

    def update
      @utils.update
      return if $game_temp.message_text
      if (@mode == :selection)
        if (Input.trigger?(:B) && @utils.check)
          c = @utils.display_message(text_get(33, 85), 2, text_get(33, 83), text_get(33, 84))
          @running = false if (c == 1)
        end
        @index = @utils.deplacement_equipe(@index, :drop)
        if (Input.trigger?(:A))
          return if ($actors[@index - 31] == nil)
          choice
        end
      elsif (@mode == :drop)
        if (Input.trigger?(:B))
          cancel_drop
        end
        if (Input.trigger?(:A))
          confirm_drop
        end
        if (Input.trigger?(:RIGHT))
          if ($storage.current_box < (PFM::Storage::MAX_BOXES - 1))
            $storage.current_box += 1
          else
            $storage.current_box = 0
          end
          @utils.change_box
        end
        if (Input.trigger?(:LEFT))
          if ($storage.current_box < 1)
            $storage.current_box = PFM::Storage::MAX_BOXES - 1
          else
            $storage.current_box -= 1
          end
          @utils.change_box
        end
      end
    end

    def create_graphics
      # Skipped to prevent glitches
    end

    def choice
      ind = @utils._party_window(text_get(33, 37), text_get(33, 41), text_get(33, 81), text_get(33, 82))
      if (ind == 0)
        drop_pokemon if @utils.check
      elsif (ind == 1)
        @utils.sumary_pokemon(@index)
      elsif (ind == 2)
        @utils.release_pokemon(@index) if @utils.check
      end
    end

    def drop_pokemon
      @pokemon_drop = $actors[@index - 31].clone
      $actors[@index - 31] = nil
      return cancel_drop if (!@utils.check)
      $actors.compact!
      @index = 0
      @utils.draw_pokemon_team
      @utils.draw_selector(@index, @pokemon_drop)
      @mode = :drop
    end

    def cancel_drop
      if (@mode == :drop)
        $actors.push(@pokemon_drop)
        @index = 30 + $actors.size
        @index = 31 if @index < 31
      else
        $actors.size.times do |i|
          if ($actors[i] == nil)
            $actors[i] = @pokemon_drop.clone
            break
          end
        end
      end
      @pokemon_drop = nil
      @utils.draw_pokemon_team
      @utils.draw_selector(@index)
      @mode = :selection
    end

    def confirm_drop
      $storage.store(@pokemon_drop)
      @pokemon_drop = nil
      @index = 31
      @utils.draw_selector(@index)
      @utils.draw_pokemon_box
      @mode = :selection
    end

    def dispose
      @utils.dispose
    end
  end
end
