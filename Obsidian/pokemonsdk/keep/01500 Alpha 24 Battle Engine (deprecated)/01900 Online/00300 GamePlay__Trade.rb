#encoding: utf-8

#noyard
module GamePlay
  class Trade < Base
    def initialize(is_server)
      super()
      @viewport = Viewport.create(:main, 1000)#select_view(view(:main, 1000))
      @background = Sprite.new(@viewport).set_bitmap("GTS", :picture)
      @actor = Sprite.new(@viewport).set_position(32, 238) #, 0)
      @other = Sprite.new(@viewport).set_position(192, 238) #, 1)
      @text = UI::SpriteStack.new(@viewport)#surface(0, 0, 320, 240, 5)
      if is_server
        @OpenNat = true
      else
        @OpenNat = nil
      end
      #Graphics.wndp_lock = true
      @update = :update_init
    end

    def update
      return unless super
      send(@update) if @update
    end

    def update_accept
      c = display_message(ext_text(9000, 94), 1, ext_text(9000, 95), ext_text(9000, 96))
      if c == 1
        send_data("NO")
        return failure(ext_text(9000, 97))
      end
      send_data("OK")
      if receive_data == "OK"
        #> Lancer animation échange
        display_message_and_wait(ext_text(9000, 98))
        evolve_check
        if @box_index >= 31
          $actors[@box_index - 31] = @other_pokemon
        else
          $storage.remove_pokemon_at(@box_index - 1)
          $pokemon_party.add_pokemon(@other_pokemon)
        end
        terminate
      else
        failure(ext_text(9000, 99))
      end
    end

    def update_init
      if @OpenNat
        @OpenNat = Online::OpenNatService.new
        check_server_validity
      else
        check_code_enter
      end
    end

    def update_wait_client
      @server = TCPServer.new("0.0.0.0", @OpenNat.private_port)
      @server.listen(10)
      while @running and !@client
        until @server.accepting?
          Graphics.update
          if Input.trigger?(:B)
            c = display_message_and_wait(ext_text(9000, 100), 1, ext_text(9000, 96), ext_text(9000, 95))
            return @running = false if c == 1
          elsif text = Input.get_text and text.getbyte(0) == 3
            Yuki.set_clipboard(@OpenNatCode)
          end
        end
        ask_trade_with(@client = @server.accept)
      end
    end

    def update_wait_server
      send_data($trainer)
      if receive_data == "OK"
        @update = :update_select_pokemon
      else
        failure(ext_text(9000, 101))
      end
    end

    def update_select_pokemon
      data = trade_select_pokemon
      unless data
        send_data(nil)
        return failure
      end
      if data >= 31
        pokemon = $actors[data - 31]
      else
        pokemon = $storage.info(data - 1)
      end
      @box_index = data
      @actor.bitmap = pokemon.battler_face
      @actor.oy = @actor.height
      @text.dispose#.bitmap.clear
      display_pokemon_info(0, pokemon)
      send_data(pokemon)
      other_pokemon = receive_data
      unless other_pokemon and other_pokemon.class == PFM::Pokemon
        return failure(ext_text(9000, 109))
      end
      @other.bitmap = other_pokemon.battler_face
      @other.oy = @other.height
      display_pokemon_info(160, other_pokemon)
      @other_pokemon = other_pokemon
      @pokemon = pokemon
      @update = :update_accept
    end

    def ask_trade_with(client)
      trainer = receive_data
      if trainer.class == PFM::Trainer
        c = display_message_and_wait(sprintf(ext_text(9000, 102), trainer.name, trainer.id % 100_000), 1,  ext_text(9000, 95), ext_text(9000, 96))
        if c == 1
          send_data("NO")
          client.close
          @client = nil
        else
          send_data("OK")
          @update = :update_select_pokemon
        end
      else
        client.close
        @client = nil
      end
    end

    def check_server_validity
      if code = get_code
        display_message(format(ext_text(9000, 103), code))
        Yuki.set_clipboard(code)
        @text.add_text(0, 0, 318, 16, "CODE : #{code}", 2, color: 2)#.bitmap.draw_shadow_text(0, 0, 320, 16, "CODE : #{code}", 2, 2)
        @update = :update_wait_client
      else
        failure(ext_text(9000, 104))
      end
    end

    def check_code_enter
      display_message_and_wait(ext_text(9000, 105))
      code = input_code
      ip_info = Online::OpenNatService.decode(code)
      unless ip_info
        c = display_message(ext_text(9000, 106), 1,  ext_text(9000, 95), ext_text(9000, 96))
        @running = false if c == 1
        return
      end
      check_client_connect(*ip_info)
      unless @client
        c = display_message(ext_text(9000, 107), 1,  ext_text(9000, 95), ext_text(9000, 96))
        @running = false if c == 1
      else
        @update = :update_wait_server
      end
    end

    def check_client_connect(ip, port)
      @client = TCPSocket.new(ip, port)
    rescue Exception
      @client = nil
    end

    PackFmt = "I"
    def send_data(data)
      data = Marshal.dump(data)
      @client.write([data.bytesize].pack(PackFmt) + data)
      return true
    rescue Exception
      return false
    end

    def receive_data(update_method = :update_receive)
      until @client.readable?
        send(update_method)
      end
      size = @client.recv(4).unpack(PackFmt).first
      data = @client.recv(size)
      while data.bytesize < size
        until @client.readable?
          send(update_method)
        end
        data << @client.recv(size - data.bytesize)
      end
      return Marshal.load(data)
    rescue Exception
      return nil
    end

    def update_receive
      Graphics.update
    end

    def failure(msg = ext_text(9000, 110))
      display_message(msg)
      terminate
    end

    def terminate
      @server.close if @server
      if @client
        @client.close
        @client = nil
      end
      @running = false
      #Graphics.wndp_lock = false
    end

    def get_code
      if !@OpenNatCode
        port = @OpenNat.open_port(20)
        return nil unless port
        display_message_and_wait(ext_text(9000, 108)) unless @OpenNat.igd_available
        return @OpenNatCode = @OpenNat.code
      end
      return nil
    end

    def trade_select_pokemon
      Graphics.freeze
      scene = GamePlay::PokemonTradeStorage.new
      scene.main
      Graphics.transition
      return scene.return_data
    end

    def input_code
      Graphics.freeze
      scene = GamePlay::NumberInput.new('', 17, 'pc_psdk', phrase: 'Entrez le code de l\'hôte :')
      scene.main
      Graphics.transition
      return scene.return_name
    end

    def evolve_check
      id, form = @other_pokemon.evolve_check(:trade, @pokemon)
      if id
        Graphics.freeze
        scene = ::GamePlay::Evolve.new(@other_pokemon, id, form, true)
        scene.main
      end
    end

    def display_pokemon_info(x, pokemon)
      x += 4
      texts = text_file_get(27)
      #bmp = @text.bitmap
      text = @text
      text.add_text(x, 0, 156, 16 ,pokemon.given_name, 1)
      text.add_text(x, 16, 156, 16,"#{texts[29]}#{pokemon.level}",0)
      text.push(x + 100, 16, nil, type: UI::GenderSprite).data = pokemon
      text.add_text(x, 32, 60, 16, text_get(23,7), 0) #Objet
      text.add_text(x + 60, 32, 94, 16, pokemon.item_name, 0)
      text.add_text(x, 48, 100, 16,texts[18],0)
      text.add_text(x, 64, 100, 16,texts[20],0)
      text.add_text(x, 80, 100, 16,texts[22],0)
      text.add_text(x, 96, 100, 16,texts[24],0)
      text.add_text(x, 112, 100, 16,texts[26],0)
      text.add_text(x, 128, 52, 16,ext_text(9000, 44),0)
      x += 100
      text.add_text(x, 48, 54, 16, pokemon.atk_basis.to_s, 2)
      text.add_text(x, 64, 54, 16, pokemon.dfe_basis.to_s, 2)
      text.add_text(x, 80, 54, 16, pokemon.ats_basis.to_s, 2)
      text.add_text(x, 96, 54, 16, pokemon.dfs_basis.to_s, 2)
      text.add_text(x, 112, 54, 16, pokemon.spd_basis.to_s, 2)
      text.add_text(x - 50, 128, 106, 16, pokemon.ability_name, 0)
    end
  end
end
