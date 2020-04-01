#encoding: utf-8

#noyard
module GamePlay
  class Storage < Base
    Start = ["PC de Palbolsky", "PC du Professeur", "Déconnexion"]
    Storage = ["Ranger les Boîtes", "Déposer des Pokémon", "Retirer des Pokémon",
              "Réarranger des objets", "Quitter"]

    def initialize(mode = nil)
      @viewport = Viewport.create(:main, 10000)
      super()
      @mode = mode 
      @running = true
    end

    def main_begin
      if @__last_scene.class == ::Scene_Map
        @__display_message_proc = proc { @__last_scene.sprite_set_update }
      end
      start_pc
      super
    end

    def main_end
      super
      Graphics.transition
    end

    def update
      @__display_message_proc.call if @__display_message_proc
      super
    end

    def create_graphics
      # Skipped to prevent glitches
    end

    def start_pc
      if (@mode == :trade)
        # traitement spécifique si échange   
      else
        display_message(format(ext_text(9000, 83), $pokemon_party.trainer.name))
        choisir_pc
      end
    end

    def choisir_pc
      start = Array.new(3) { |i| ext_text(9000, 73 + i) }
      c = display_message(ext_text(9000, 84), 1, *start)
      case c
      when 0 # PC de Stockage
        storage_pc
      when 1 # PC du Professeur
        professor_pc
      when 2 # Déconnexion   
        @running = false
      end  
    end

    def storage_pc
      storage = Array.new(5) { |i| ext_text(9000, 77 + i) }
      c = display_message(ext_text(9000, 85), 1, *storage)
      while $game_temp.message_window_showing && @running
        @message_window.update
        Graphics.update
      end
      case c
      when 0 # Ranger les Boîtes
        call_scene(StorageMove)   
      when 2 # Déposer des Pokémon
        call_scene(StorageDrop)
      when 1 # Retirer des Pokémon          
        call_scene(StorageRemove)    
      when 3 # Réarranger des objets 
        call_scene(StorageItems) 
      when 4 # Quitter
        choisir_pc
      end
      storage_pc if (c != 4)
    end

    def professor_pc
      display_message(ext_text(9000, 86))
      choisir_pc
    end

    def _party_window(*args)
      window=Window_Choice.new(105,args)
      window.z=@viewport.z+1
      window.x=213
      window.y=238-window.height
      disabled=[]
      args.each_index do |i|
        cmd=args[i]
      end
      loop do
        Graphics.update
        window.update
        if window.validated?
          if(disabled.include?(window.index))
            $game_system.se_play($data_system.buzzer_se)
          else
            $game_system.se_play($data_system.decision_se)
            break
          end
        elsif(Input.trigger?(:B))
          window.index=args.size
          break
        end
      end
      index=window.index
      window.dispose
      return index
    end

    def dispose
      @message_window.dispose
      @viewport.dispose 
    end
  end
end

