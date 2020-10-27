#encoding: utf-8

#noyard
module GamePlay
  class StorageRemove < Base
    RET = "Retirer"
    INF = "Résumé"
    REL = "Relâcher"
    QTT = "Quitter"
    def initialize
      super()
      @utils = StorageUtils.new
      @index = 1
      @utils.draw_selector(@index)
      @running = true
    end

    def create_graphics
      # Skipped to prevent glitches
    end

    def update
      @utils.update
      return if $game_temp.message_text
      if (Input.trigger?(:B) && @utils.check)
        c = @utils.display_message(text_get(33, 85), 2, text_get(33, 83), text_get(33, 84))
        @running = false if (c == 1)
      end
      if (@index == 0) # Changement de boîte
        @index = @utils.changer_boite(@index)
      else # Déplacement dans la boîte
        @index = @utils.deplacement_boite(@index, :remove)
        if (Input.trigger?(:A))
          return if (!$storage.slot_contain_pokemon?(@index - 1))
          choice
        end
      end
    end

    def choice
      arr = Array.new
      arr.push(text_get(33, 38), text_get(33, 41), text_get(33, 81), text_get(33, 82))
      ind = @utils._party_window(*arr)
      if (ind == 0)
        remove_pokemon
      elsif (ind == 1)
        @utils.sumary_pokemon(@index)
      elsif (ind == 2)
        @utils.release_pokemon(@index) if $pokemon_party.actors.size > 0
      end
    end

    def remove_pokemon
      if ($pokemon_party.actors.size > 5)
        @utils.display_message(text_get(33, 91), 1)
        return
      end
      pokemon = $storage.remove_pokemon_at(@index - 1)
      $pokemon_party.actors.push(pokemon)
      @utils.draw_init
      @utils.draw_info_pokemon(@index)
    end

    def dispose
      @utils.dispose
    end
  end
end
