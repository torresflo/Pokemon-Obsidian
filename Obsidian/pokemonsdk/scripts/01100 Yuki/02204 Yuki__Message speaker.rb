module Yuki
  class Message
    private

    # @return [Hash{String=>Symbol}] function to call when a thing= (String) is detected inside the :[...]: tag
    PARSER = {
      'name=' => :parse_speaker_name,
      'face=' => :parse_speaker_face,
      'city=' => :parse_city_image,
      'can_skip' => :parse_can_skip,
      'windowskin=' => :parse_window_skin,
      'lookto=' => :look_to_event
    }

    # Parse the speakers information
    # @param info_str [String] string containing all the informations
    # @example example of info_str
    #   name=Yuri the scripter;face=0,032;face=-64,026,128
    #   The speaker will be Yuri the scripter
    #   His face will be Graphics/Battlers/032.png
    #   His face will be shown at the coordinate x = 0 (centered)
    #   Another face is shown at the coordinate x = Viewport.width - 64
    #   This face will be Graphics/Battlers/026.png
    #   This face will have the opacity 128
    #   Note : The face order is important, the first defined will be below the second one
    def parse_speaker(info_str)
      @face_stack.dispose
      info_str.split(';').each do |sub_info_str|
        PARSER.each do |type, method_name|
          break(send(method_name, sub_info_str.split('=').last)) if sub_info_str.start_with?(type)
        end
      end
      viewport.sort_z
      self.face_opacity = opacity
      nil
    end

    # Parse the speaker name
    # @param name [String] name of the speaker
    def parse_speaker_name(name)
      @name_window.visible = true
      @name_window.lock
      @name_window.set_origin(0, 0)
      @name_window.width = @name_text.text_width(name) + @name_window.window_builder[4] + @name_window.window_builder[-2]
      @name_window.unlock
      @name_text.text = name
    end

    # Parse the face of a speaker
    # @param info_str [String] infos about the face (position,name,opacity,mirror)
    def parse_speaker_face(info_str)
      position, name, opacity, mirror = info_str.split(',')
      sprite = @face_stack.push(parse_speaker_position(position.to_i), face_speaker_y, name.to_s)
      sprite.set_origin(sprite.width / 2, sprite.height)
      sprite.opacity = opacity.to_i if opacity
      sprite.mirror = mirror == 'true'
      sprite.instance_variable_set(:@opacity, sprite.opacity)
    end

    # Function that translate the position to a coordinate
    # @param position [Integer] position given by the maker
    # @return [Integer] the x position
    def parse_speaker_position(position)
      position = viewport.rect.width + position if position < 0
      return position
    end

    # Update the value of the face opacity
    def face_opacity=(value)
      @face_stack.stack.each do |sprite|
        sprite.opacity = value * sprite.instance_variable_get(:@opacity) / 255
      end
    end

    # Return the face_speaker y position
    # @return [Integer]
    def face_speaker_y
      return viewport.rect.height # if position == :top
      # y
    end

    # Parse the image setting of the city
    # @param name [String] name of the image in Pictures
    def parse_city_image(name)
      @city_sprite ||= Sprite.new(self)
      @city_sprite.z = z + 1
      @city_sprite.opacity = 0
      @city_sprite.set_bitmap(name, :picture)
    end

    # Parse the can skip authorisation
    # @param _ignored [String] ignored param
    def parse_can_skip(_ignored)
      @can_skip_message = true
    end

    # Parse the message box windowsking change
    # @param windowskin [String] name of the temporary windowskin
    def parse_window_skin(windowskin)
      @windowskin_overwrite = windowskin
    end

    # Turn the player toward the event of it's choice
    # @param event [String] the info about the chosen event
    # @example example of event
    #   If you want your player to turn to the talking event, write :[lookto=] or :[lookto=0]
    #   If you want your player to turn to another event, write :[lookto=X] where X is the event's id
    #   Take care to always write the id without the first 0. Example : 036 should always be written 36.
    def look_to_event(event = '0')
      event = event.to_i
      event == 0 ? $game_player.look_to($game_system.map_interpreter.event_id) : $game_player.look_to(event)
    end
  end
end
