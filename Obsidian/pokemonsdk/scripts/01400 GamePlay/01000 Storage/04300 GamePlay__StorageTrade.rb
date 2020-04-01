#encoding: utf-8

#noyard
module GamePlay
  class StorageTrade
    ECH = "Échanger"
    INF = "Résumé"
    QTT = "Quitter"

    attr_accessor :return_data
    def initialize
      super()
      @utils = StorageUtils.new
      @index = 1
      @utils.draw_selector(@index)
      @arr = [ext_text(9000, 90), text_get(33, 41), text_get(33, 82)]
      @running = true
    end

    def create_graphics
      # Skipped to prevent glitches
    end

    def main
      @last_scene = $scene
      $scene = self
      Graphics.transition
      while(@running)
        Graphics.update
        update
      end
      Graphics.freeze
      dispose
      $scene = @last_scene
    end

    def update
      @utils.update
      return if $game_temp.message_text
      if Input.trigger?(:B)
        c = @utils.display_message(ext_text(9000, 87), 2, text_get(33, 83), text_get(33, 84))
        @return_data = nil
        @running = false if (c == 0)
      end
      if (@index == 0) # Changement de boîte
        @index = @utils.changer_boite(@index)
      elsif (@index > 0 and @index < 31)# Déplacement dans la boîte
        @index = @utils.deplacement_boite(@index)
        if (Input.trigger?(:A))
          choice($storage.info(@index - 1))
        end
      else # Déplacement dans l'équipe
        @index = @utils.deplacement_equipe(@index)
        if (Input.trigger?(:A))
          choice($actors[@index - 31])
        end
      end
    end

    def choice(pokemon)
      return unless pokemon and !pokemon.egg?
      ind = @utils._party_window(*@arr)
      case ind
      when 1
        @utils.sumary_pokemon(@index)
      when 0
        @return_data = @index
        @running = false
      end
    end

    def dispose
      @utils.dispose
    end
  end
end
