#encoding: utf-8

=begin
module Yuki
  # The Visual Debug script of PSDK
  module VisualDebug
    # Framerate information
    FrameRate = "Framerate : %d FPS"
    # InGame time information
    TimeText = "Heure : %02d:%02d (vit: %d) Jour : %02d/%02d Moment : %s"
    # InGame time disabled information
    TimeDis = "Temps désactivé"
    # Moment of the day
    Moments = ["Nuit","Soir","Matin","Jour"]
    # No active evenet information
    NoEvent = "Aucun évènement actif..."
    # Name of the current running Event
    Event = "Evènement : %s"
    # Encounter enabled
    RencA = "Rencontres activées"
    # Encounter disabled
    RencD = "Rencontres désactivées"
    # Encounter zone information
    RencT = "Zone de rencontre : %d"
    # Encounter tag information
    RencTag = "Groupe sur le Tag %d"
    # Encounter fishing information
    RencPeche = "Pêche avec %s (canne)"
    # Encounter roaming information
    RencFuyard = "Pokémon Fuyards actifs..."
    # Encounter Rock Smash information
    RencRock = "Pokémon par éclate rock..."
    # Encounter Head Butt information
    RencHeadbutt = "Pokémon par coud'boule"
    # Icon name format
    IconName = "%03d"
    # Text character width
    TextCharW = 6
    # Text character height
    TextCharH = 16
    module_function
    # Is the visual debug enabled ? 
    def enabled?
      @text and !@text.disposed?
    end
    # Update the visual debug
    def update
      if $game_temp.in_battle

      else
        update_map
      end
      update_framerate
    end
    # Update the framerate information
    def update_framerate
      @frame_counter += 1
      if(@frame_counter == 60)
        current_time = Time.new
        draw_text(0, 0, sprintf(FrameRate, 60 / (current_time - @last_time)))
        @last_time = current_time
        @frame_counter = 0
      end
    end
    # Update the map debug info
    def update_map
      update_map_player
      update_map_event
      update_map_encounter
      update_map_time
      update_wild_pokemon
      update_click
    end
    # Update on the click action
    def update_click
      if Mouse.trigger?(:left)
        if @systag_sprite.simple_mouse_in? or @frontsystag_sprite.simple_mouse_in?
          disable
          SystemTagEditor.start
          enable
        end
      end
    end
    # Update the wild pokemon information
    def update_wild_pokemon
      zt = $env.get_zone_type
      fzt = $env.convert_zone_type($game_player.front_system_tag)
      if zt != @last_zt or $wild_battle.code != @wi_code or fzt != @last_fzt
        bmp = @text.bitmap
        bmp.clear_rect(0, 80, 640, 400) #bmp.fill_rect(0, 80, 640, 400, GameData::Colors::Transparent)
        draw_text(0, 208, sprintf(RencT, zt))
        groups = $wild_battle.remaining_pokemons[zt]
        if(groups)
          y = 224
          8.times do |i|
            if groups[i].class == PFM::Wild_Info
              update_draw_pokemons(bmp, 0, y, groups[i].ids, sprintf(RencTag, i))
              y += 32
            end
          end
        end
        #> Pêche
        y = 80
        groups = $wild_battle.fishing
        if(groups[:normal][fzt].class == PFM::Wild_Info)
          update_draw_pokemons(bmp, 0, y += 32, groups[:normal][fzt].ids, sprintf(RencPeche, :normal))
        end
        if(groups[:super][fzt].class == PFM::Wild_Info)
          update_draw_pokemons(bmp, 0, y += 32, groups[:super][fzt].ids, sprintf(RencPeche, :super))
        end
        if(groups[:mega][fzt].class == PFM::Wild_Info)
          update_draw_pokemons(bmp, 0, y += 32, groups[:mega][fzt].ids, sprintf(RencPeche, :mega))
        end
        y = 80
        if(groups[:rock][fzt].class == PFM::Wild_Info)
          update_draw_pokemons(bmp, 320, y += 32, groups[:rock][fzt].ids, RencRock)
        end
        if(groups[:headbutt][fzt].class == PFM::Wild_Info)
          update_draw_pokemons(bmp, 320, y += 32, groups[:headbutt][fzt].ids, RencHeadbutt)
        end
        #> Fuyards
        update_draw_roaming(bmp, $wild_battle.roaming_pokemons)
        @wi_code = $wild_battle.code
        @last_zt = zt
        @last_fzt = fzt
      end
    end
    # Draw the roaming Pokemon informations
    # @param bmp [Bitmap] the bitmap where to draw the Roaming Pokemon
    # @param group [Array] list of PFM::Wild_*Info
    def update_draw_roaming(bmp, group)
      return if group.size < 1
      x = ini_x = 320
      bmp.clear_rect(x, 0, 320, 80) #bmp.fill_rect(x, 0, 320, 80, GameData::Colors::Transparent)
      bmp.draw_text(x, 0, 320, 16, RencFuyard)
      y = 16
      group.each do |info|
        next unless info.class == ::PFM::Wild_RoamingInfo
        icon = RPG::Cache.b_icon(sprintf(IconName, info.pokemon.id))
        bmp.blt(x, y, icon, icon.rect, info.could_appear? ? 255 : 160)
        x += 32
        if x >= 640
          x = ini_x
          y += 32
        end
      end
    end
    # Draw a pokemon group
    # @param bmp [Bitmap] the bitmap where to draw the Pokemon
    # @param x [Integer] the x position where to start drawing Pokemon
    # @param y [Integer] the y position where to start drawing Pokemon
    # @param ids [Array<Integer>] the list of Pokemon ID
    # @param text [String] the text information about the group
    def update_draw_pokemons(bmp, x, y, ids, text)
      bmp.draw_text(x, y, 320, 16, text)
      icon = id = nil
      ids.each do |id|
        next unless id
        icon = RPG::Cache.b_icon(sprintf(IconName, id))
        bmp.blt(x, y, icon, icon.rect)
        x += 32
      end
    end
    # Update the map player information (system tag)
    def update_map_player
      px = $game_player.x
      py = $game_player.y
      pd = $game_player.direction
      @ghost_mode.visible = $game_player.through
      @sliding_mode.visible = $game_player.sliding?

      if(@last_x != px or @last_y != py or @last_d != pd)
        @blocked_mode.visible = !@chara.passable?(px, py, pd)
        @surfing_mode.visible = $game_player.surfing?
        system_tag = $game_player.system_tag - 384
        system_tag = 0 if system_tag < 0
        @systag_sprite.src_rect.set(32 * (system_tag % 8), 32 * (system_tag / 8), 32, 32)
        system_tag = $game_player.front_system_tag - 384
        system_tag = 0 if system_tag < 0
        @frontsystag_sprite.src_rect.set(32 * (system_tag % 8), 32 * (system_tag / 8), 32, 32)
        @last_x = px
        @last_y = py
        @last_d = pd
      end
    end
    # Update the map event information
    def update_map_event
      if($game_system.map_interpreter.running?)
        eid = $game_system.map_interpreter.event_id
        if(eid != @last_event_id)
          draw_text(0, 64, sprintf(Event, $game_map.events[eid].event.name)) if $game_map.events[eid]
          @last_event_id = eid
        end
      elsif(@last_event_id)
        draw_text(0, 64, NoEvent)
        @last_event_id = nil
      end
    end
    # Update the map encounter state information
    def update_map_encounter
      if($game_system.encounter_disabled != @encounter)
        @encounter = $game_system.encounter_disabled
        draw_text(0, 80, @encounter ? RencD : RencA)
      end
    end
    # Update the time information
    def update_map_time
      if($game_switches[Sw::TJN_NoTime])
        return  draw_text(0, 16, TimeDis)
      end

      if(@last_min != $game_variables[Var::TJN_Min])
        @last_min = $game_variables[Var::TJN_Min]
        draw_text(0, 16, sprintf(TimeText, 
            $game_variables[Var::TJN_Hour],
            $game_variables[Var::TJN_Min],
            TJN::MIN_FRAMES,
            $game_variables[Var::TJN_MDay],
            $game_variables[Var::TJN_Month],
            Moments[$game_variables[Var::TJN_Tone]]
          )
        )
      end
    end
    # Enable the Visual debug
    def enable
      @last_time = Time.new
      @frame_counter = 0
      @last_x = -1
      @last_y = -1
      @last_d = -1
      @last_min = -1
      @encounter = nil
      @last_event_id = -1
      @wi_code = nil
      @last_zt = -1
      @last_fzt = -1
      @viewport = Viewport.new(0,0,640,480)
      @viewport.z = 15_000
      @text = ::Sprite.new(@viewport)
      @text.z = 1
      @text.bitmap = Bitmap.new(640, 480)
      @text.bitmap.font.set_small_font

      @systag_sprite = Utils.create_sprite(@viewport, "prio_w", 0, 32, 1, 
        sprite_class: ::Sprite, cache_name: :tileset, scr_rect: [0, 0, 32, 32])
      @frontsystag_sprite = Utils.create_sprite(@viewport, "prio_w", 32, 32, 2, 
        sprite_class: ::Sprite, cache_name: :tileset, scr_rect: [0, 0, 32, 32])
      @ghost_mode = Utils.create_sprite(@viewport, "353", 0, 32, 3, 
        sprite_class: ::Sprite, cache_name: :b_icon)
      @ghost_mode.opacity = 220
      @blocked_mode = Utils.create_sprite(@viewport, "143", 32, 32, 4,
        sprite_class: ::Sprite, cache_name: :b_icon)
      @surfing_mode = Utils.create_sprite(@viewport, "131", 64, 32, 4,
        sprite_class: ::Sprite, cache_name: :b_icon)
      @sliding_mode = Utils.create_sprite(@viewport, "220", 64, 32, 5,
        sprite_class: ::Sprite, cache_name: :b_icon)

      @chara = Game_Character.new
    end
    # Disable the visual debug
    def disable
      @text.bitmap.dispose
      @text.dispose
      @text = nil
      @systag_sprite.dispose
      @frontsystag_sprite.dispose
      @ghost_mode.dispose
      @blocked_mode.dispose
      @surfing_mode.dispose
      @sliding_mode.dispose
      @viewport.dispose
      @viewport = nil
    end
    # Clear the visual debug text layer
    def clear
      return unless enabled?
      @text.bitmap.clear
      @last_x = -1
      @last_y = -1
      @last_d = -1
      @last_min = -1
      @last_event_id = -1
      @encounter = nil
      @wi_code = nil
      @last_zt = -1
      @last_fzt = -1
      @sliding_mode.visible = @surfing_mode.visible = @blocked_mode.visible = 
      @ghost_mode.visible = false
      @systag_sprite.src_rect.set(-32, 0, 32, 32)
      @frontsystag_sprite.src_rect.set(-32, 0, 32, 32)
    end
    # Draw a text
    # @param x [Integer] x position of the text
    # @param y [Integer] y position of the text
    # @param text [String] text to draw
    def draw_text(x, y, text)
      width = text.bytesize * TextCharW
      @text.bitmap.clear_rect(x, y, width, TextCharH) #@text.bitmap.fill_rect(x, y, width, TextCharH, GameData::Colors::Transparent)
      @text.bitmap.draw_text(x, y, width, TextCharH, text)
    end
  end
end
=end
