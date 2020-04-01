#encoding: utf-8

#noyard
module RPG
  class Sprite < ::Sprite
    @@_animations = []
    @@_reference_count = {}
    def initialize(viewport = nil)
      super(viewport)
      @_whiten_duration = 0
      @_appear_duration = 0
      @_escape_duration = 0
      @_collapse_duration = 0
      @_damage_duration = 0
      @_animation_duration = 0
      @_blink = false
      @_reverse = false
      @_option = 0
      @_registered_x = 0
      @_registered_y = 0
      @_registered_ox = 0
      @_registered_oy = 0
    end

    def register_position
      @_registered_x = self.x
      @_registered_ox = self.ox
      @_registered_y = self.y
      @_registered_oy = self.oy
    end

    def reset_position
      self.x = @_registered_x
      self.ox = @_registered_ox
      self.y = @_registered_y
      self.oy = @_registered_oy
    end

    def dispose_animation
      if @_animation_sprites != nil
        sprite = @_animation_sprites[0]
        for sprite in @_animation_sprites
          sprite.dispose
        end
        @_animation_sprites = nil
        @_animation = nil
      end
    end

    def dispose_loop_animation
      if @_loop_animation_sprites != nil
        sprite = @_loop_animation_sprites[0]
        for sprite in @_loop_animation_sprites
          sprite.dispose
        end
        @_loop_animation_sprites = nil
        @_loop_animation = nil
      end
    end

    
    def animation(animation, hit, reverse = false)
      dispose_animation
      @_animation = animation
      return if @_animation == nil
      @_animation_hit = hit
      @_animation_duration = @_animation.frame_max
      animation_name = @_animation.animation_name
      animation_hue = @_animation.animation_hue
      bitmap = RPG::Cache.animation(animation_name, animation_hue)
=begin
      if @@_reference_count.include?(bitmap)
        @@_reference_count[bitmap] += 1
      else
        @@_reference_count[bitmap] = 1
      end
=end
      @_animation_sprites = []
      if @_animation.position != 3 or not @@_animations.include?(animation)
        for i in 0..15
          sprite = ::Sprite.new(self.viewport)
          sprite.bitmap = bitmap
          sprite.visible = false
          @_animation_sprites.push(sprite)
        end
        unless @@_animations.include?(animation)
          @@_animations.push(animation)
        end
      end
      @_reverse = reverse
      if animation.name.include?('/')
        split_list = animation.name.split('/')
        if split_list.length == 2
          if split_list[0].include?("R")
            @_option = 1
          end
          if split_list[0].include?("N")
            @_reverse = false
          end
          if split_list[0].include?("M")
            @_option = 2
          end
        end
      end
      update_animation
    end

    def update
      super
      if @_whiten_duration > 0
        @_whiten_duration -= 1
        self.color.alpha = 128 - (16 - @_whiten_duration) * 10
      end
      if @_appear_duration > 0
        @_appear_duration -= 1
        self.opacity = (16 - @_appear_duration) * 16
      end
      if @_escape_duration > 0
        @_escape_duration -= 1
        self.opacity = 256 - (32 - @_escape_duration) * 10
      end
      if @_collapse_duration > 0
        @_collapse_duration -= 1
        self.opacity = 256 - (48 - @_collapse_duration) * 6
      end
      if @_damage_duration > 0
        @_damage_duration -= 1
        case @_damage_duration
        when 38..39
          @_damage_sprite.y -= 4
        when 36..37
          @_damage_sprite.y -= 2
        when 34..35
          @_damage_sprite.y += 2
        when 28..33
          @_damage_sprite.y += 4
        end
        @_damage_sprite.opacity = 256 - (12 - @_damage_duration) * 32
        if @_damage_duration == 0
          dispose_damage
        end
      end
      if @_animation != nil and (Graphics.frame_count % 3 == 1) # % 2 == 0
        @_animation_duration -= 1
        update_animation
      end
      if @_loop_animation != nil and (Graphics.frame_count % 3 == 1) # % 2 == 0
        update_loop_animation
        @_loop_animation_index += 1
        @_loop_animation_index %= @_loop_animation.frame_max
      end
      if @_blink
        @_blink_count = (@_blink_count + 1) % 32
        if @_blink_count < 16
          alpha = (16 - @_blink_count) * 6
        else
          alpha = (@_blink_count - 16) * 6
        end
        self.color.set(255, 255, 255, alpha)
      end
      @@_animations.clear
      self.viewport.update if self.viewport != nil
    end

    def animation_set_sprites(sprites, cell_data, position)
      # Cas Spécial : le sprite de mouvement du Pokémon
      sprite = sprites[15]
      pattern = cell_data[15, 0]
      jump = false
      if sprite == nil or pattern == nil or pattern == -1
        sprite.visible = false if sprite != nil
        jump = true
      end

      x_compensate = 0
      y_compensate = 0

      if not jump
        if position == 3
          if self.viewport != nil
            self.x = self.viewport.rect.width / 2
            self.y = (self.viewport.rect.height - 48) / 2 #self.viewport.rect.height - 160
          else
            self.x = Graphics.width / 2#320
            self.y = Graphics.height / 2#240
          end
        else
          self.x = @_registered_x
          self.y = @_registered_y
        end

        if @_reverse and position == 3
          self.x = 320 - self.x #620 - self.x
          self.y = 220 - self.y #440 - self.y #328 - self.y
          #self.ox = self.src_rect.width / 2
          #self.oy = self.src_rect.height / 2
        end

        if not @_reverse
          self.x += cell_data[15, 1] / 2 #cell_data[15, 1]
          self.y += cell_data[15, 2] / 2 #cell_data[15, 2]
          x_compensate -= cell_data[15, 1] / 2 if position != 3#cell_data[15, 1] if position != 3
          y_compensate -= cell_data[15, 2] / 2 if position != 3#cell_data[15, 2] if position != 3
        else
          self.x -= cell_data[15, 1] / 2 #cell_data[15, 1]
          self.y -= cell_data[15, 2] / 2 #cell_data[15, 2]
          x_compensate += cell_data[15, 1] / 2 if position != 3#cell_data[15, 1] if position != 3
          y_compensate += cell_data[15, 2] / 2 if position != 3#cell_data[15, 2] if position != 3
        end
      end

      for i in 0..14
        sprite = sprites[i]
        pattern = cell_data[i, 0]
        if sprite == nil or pattern == nil or pattern == -1
          sprite.visible = false if sprite != nil
          next
        end

        sprite.visible = true
        sprite.src_rect.set(pattern % 5 * 192, pattern / 5 * 192, 192, 192)

        if position == 3
          if self.viewport != nil
            sprite.x = self.viewport.rect.width / 2
            sprite.y = (self.viewport.rect.height - 48) / 2#384 - 160#self.viewport.rect.height - 160
          else
            sprite.x = Graphics.width / 2#320
            sprite.y = Graphics.height / 2#240
          end
        else
          sprite.x = self.x - self.ox + self.src_rect.width / 2
          sprite.y = self.y - self.oy / 2
          sprite.y -= self.src_rect.height / 4 if position == 0
          sprite.y += self.src_rect.height / 4 if position == 2
=begin
          sprite.y = self.y - self.oy + self.src_rect.height / 2
          sprite.y -= self.src_rect.height / 4 if position == 0
          sprite.y += self.src_rect.height / 4 if position == 2
=end
        end

        if @_reverse and position == 3
          sprite.x = 320 - sprite.x#620 - sprite.x
          sprite.y = 220 - sprite.y#328 - sprite.y
        end

        if not @_reverse
          sprite.x += cell_data[i, 1].to_i / 2 + x_compensate # / 2 added
          sprite.y += cell_data[i, 2].to_i / 2 + y_compensate # / 2 added
        else
          sprite.x -= cell_data[i, 1].to_i / 2 - x_compensate # / 2 added
          sprite.y -= cell_data[i, 2].to_i / 2 - y_compensate # / 2 added
        end

        sprite.z = 2000
        sprite.ox = 96
        sprite.oy = 96
        sprite.zoom_x = cell_data[i, 3].to_i / 100.0 / 2 # / 2 added
        sprite.zoom_y = cell_data[i, 3].to_i / 100.0 / 2 # / 2 added
        sprite.angle = cell_data[i, 4].to_i
        if @_option == 1 and @_reverse
          sprite.angle += 180
        end
        sprite.mirror = (cell_data[i, 5] == 1)
        if @_option == 2 and @_reverse
          sprite.mirror = (sprite.mirror == false)
        end
        sprite.opacity = cell_data[i, 6].to_i * self.opacity / 255.0
        sprite.blend_type = cell_data[i, 7]
      end
    end
  end

end

