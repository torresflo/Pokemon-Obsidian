#encoding: utf-8

#noyard
module Online
  module Map
    Task = proc { Online::Map.update }
    TaskName = "Online::Map.update"

    module_function
    def start(is_server = false)
      return if @running
      @OpenNat = is_server ? true : nil
      @OpenNatCode = nil
      @text = UI::SpriteStack.new(nil)
      @code_base = 123
      @base_port = 1560
      add_task
      @update = :update_init
    end

    def update
      return remove_task unless @running
      return if $game_temp.message_window_showing
      Yuki.set_clipboard(@OpenNatCode) if @OpenNatCode and text = Input.get_text and text.getbyte(0) == 3
      send(@update)
    end

    def update_init
      if @OpenNat
        @OpenNat = Online::OpenNatService.new
        check_server_validity
      else
        $scene.display_message("Entrez le code de votre partenaire.\r\nVous pouvez utiliser CTRL+V pour le coller.")
        @update = :update_code
      end
    end

    def update_code
      code = input_code
      ip_info = Online::OpenNatService.decode(code, @code_base)
      unless ip_info
        c = $scene.display_message("Le code est invalide, désirez réentrer le code ?", 1, "Oui", "Non")
        @running = false if c == 1
        return
      end
      check_client_connect(*ip_info)
      unless @server
        c = $scene.display_message("Le partenaire désigné par le code ne répond pas...\nDésirez vous entrer un autre code ?", 1, "Oui", "Non")
        @running = false if c == 1
      else
        @update = :update_client
      end
    end

    def check_client_connect(ip, port)
      @server = TCPSocket.new(ip, port)
    rescue Exception
      @server = nil
    end

    def check_server_validity
      if code = get_code
        $scene.display_message("Votre code est \\c[2]#{code}\\c[0], donnez le à votre partenaire...\r\nVous pouvez utiliser CTRL+C pour le copier.")
        Yuki.set_clipboard(code)
        @text.add_text(0, 16, 320, 16, "CODE : #{code}", 2, color: 2) if @text
        @update = :update_server
      else
        failure("PSDK n'a pas réussi à ouvrir un port...")
      end
    end

    def attempt_get_port_for_battle
      @OpenNat = Online::OpenNatService.new
      @OpenNatCode = nil
      @code_base = Scene_Battle_Online::CodeBase
      @base_port = 2270
      check_server_validity
      Scene_Battle_Online.code = @OpenNatCode
      @running = false
    end

    def failure(msg = "La connexion a été intérompue.")
      $scene.display_message(msg)
      terminate
    end

    def terminate
      @server.close if @server
      if @clients
        @clients.each { |client| client.close }
        @clients = nil
      end
      @running = false
    end

    def get_code
      if !@OpenNatCode
        obj = @OpenNat
        result = obj.open_port(20, @base_port)
        return @OpenNatCode = obj.code(@code_base) if result
      end
      return nil
    end

    def input_code
      Graphics.freeze
      scene = GamePlay::NumberInput.new('', 17, 'pc_psdk', phrase: 'Entrez le code de l\'hôte :')
      scene.main
      Graphics.transition
      return scene.return_name
    end

    def add_task
      Scheduler.add_message(:on_update, ::Scene_Map, TaskName, 1500, self, :update)
    end

    def remove_task
      Scheduler.__remove_task(:on_update, ::Scene_Map, TaskName, 1500)
      @text.dispose
      @text = nil
      terminate
    end
  end
end
