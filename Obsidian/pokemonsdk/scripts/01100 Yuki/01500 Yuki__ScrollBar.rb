#encoding: utf-8

module Yuki
  # A little scrollbar display.
  #
  # This generate the scrollbar with a scroll_parameter Hash.
  # The keys of this hash are :
  #   up_button: opt String # Image name of the up button in Graphics/Windowskin/
  #   down_button: opt String # Image name of the down button in Graphics/Windowskin/
  #   bar: opt String # Image name of the bar button in Graphics/Windowskin/
  #   back: opt String # Image name of the bar background in Graphics/Windowskin/
  #   no_action: opt Boolean # if the bar does not change the sprite it scroll and call the callback
  #   scroll_unit: opt Integer # Number of pixel each click on Up/Down add to the scrolled sprite
  #   sprite_class: opt Class # Class used to generate the scroll bar sprites (default : Sprite)
  #   callback: opt Method # The method object that is called when a click on up/down is done
  class ScrollBar
    # Scrollbar up button
    SBU = "int_scroll_up"
    # Scrollbar down button
    SBD = "int_scroll_down"
    # Scrollbar background
    SBK = "int_scroll_background"
    # Scrollbar middle button
    SBB = "int_scroll_button"
    # Create a new scrollbar
    # @param sprite [Sprite] the sprite that is scrolled
    # @param scroll_parameter [Hash] the scroll_parameter Hash
    def initialize(sprite, scroll_parameter)
      @main_sprite = sprite
      @surface = sprite.src_rect.clone
      @sprite_stack = Array.new(4)
      @no_action = scroll_parameter.fetch(:no_action, false)
      @scroll_unit = scroll_parameter.fetch(:scroll_unit, 16)
      @callback = scroll_parameter.fetch(:callback, nil)
      instanciate_sprite(scroll_parameter)
    end
    # Instanciate the sprite according to the scroll_parameter
    # @param scroll_parameter [Hash] the scroll_parameter Hash
    def instanciate_sprite(scroll_parameter)
      up_bmp = RPG::Cache.windowskin(scroll_parameter.fetch(:up_button, SBU))
      down_bmp = RPG::Cache.windowskin(scroll_parameter.fetch(:down_button, SBD))
      bar_bmp = RPG::Cache.windowskin(scroll_parameter.fetch(:bar, SBB))
      back_bmp = RPG::Cache.windowskin(scroll_parameter.fetch(:back, SBK))
      sprite_class = scroll_parameter.fetch(:sprite_class, Sprite)
      sp = @sprite_stack
      viewport = @main_sprite.viewport
      z = @main_sprite.z + 1
      base_y = @main_sprite.y
      base_x = @main_sprite.x + @surface.width# - up_bmp.width
      @unclick = csp = sp[0] = sprite_class.new(viewport)
      csp.x = base_x
      csp.y = base_y
      csp.z = z
      csp.bitmap = up_bmp
      csp.src_rect.set(0,0,up_bmp.width, up_bmp.height / 2)
      csp = sp[1] = sprite_class.new(viewport)
      csp.x = base_x
      csp.y = base_y + @surface.height - down_bmp.height / 2
      csp.z = z
      csp.bitmap = down_bmp
      csp.src_rect.set(0,0,down_bmp.width, down_bmp.height / 2)
      csp = sp[2] = sprite_class.new(viewport)
      csp.x = base_x
      @scroll_min_y = csp.y = base_y + up_bmp.height / 2
      @scroll_delta_y = sp[1].y - bar_bmp.height - @scroll_min_y
      csp.z = z + 1
      csp.bitmap = bar_bmp
      csp.src_rect.set(0,0,bar_bmp.width / 2, bar_bmp.height)
      csp = sp[3] = sprite_class.new(viewport)
      csp.x = base_x
      csp.y = @scroll_min_y
      csp.z = z
      csp.bitmap = Bitmap.new(back_bmp.width, @surface.height - (down_bmp.height - up_bmp.height) / 2)
      base_y = 0
      while base_y < csp.bitmap.height
        csp.bitmap.blt(0, base_y, back_bmp, back_bmp.rect)
        base_y += back_bmp.height
      end
      @main_sprite.src_rect.height = @surface.height
      load_parameters
    end
    # Update the scrollbar
    def update
      return false if @no_action
      #> S'il y a clic
      if Mouse.press?(:left)
        return true if check_click
      else
        #> On réinit le dernier bouton puis oublie la dernière position souris
        unclick
        @my = nil
      end
      #> S'il y a scroll
      if Mouse.wheel != 0 and @main_sprite.simple_mouse_in?
        check_scroll
      end
      return false
    end
    # Check click on scrollbar buttons
    def check_click
      mx = Mouse.x
      my = Mouse.y
      if(@main_sprite.viewport)
        vrect = @main_sprite.viewport.rect
        mx -= vrect.x
        my -= vrect.y
      end
      csp = @sprite_stack[0]
      repeat = Mouse.trigger?(:left)#Input.krepeat?(1)
      in_bar = false
      #> Si c'est dans la scrollbar
      if(mx >= csp.x and mx < (csp.x+csp.bitmap.width) and my >= csp.y)
        in_bar = true
        #> Si on clique sur le bouton haut
        if repeat and my < @scroll_min_y
          unclick(csp)
          csp.src_rect.y = csp.src_rect.height
          return update_position(-@scroll_unit)
        end
        csp = @sprite_stack[1]
        #> Si on clique sur le bouton bas
        if repeat and my >= csp.y and my < (@main_sprite.y+@surface.height)
          unclick(csp)
          csp.src_rect.y = csp.src_rect.height
          return update_position(@scroll_unit)
        end
      end
      csp = @sprite_stack[2]
      #> Si on clique sur le bouton du milieu
      if (csp.src_rect.x != 0) or 
        (in_bar and my >= csp.y and my <= (csp.y + csp.bitmap.height))
        unclick(csp)
        csp.src_rect.x = csp.src_rect.width
        if @my and @max > 0 and @scroll_delta_y > 0
          update_position((my - @my) * @max / @scroll_delta_y)
        end
        @my = my
        return true
      end
      false
    end
    # Check the scroll of the mouse wheel
    def check_scroll
      update_position(- Mouse.wheel * @scroll_unit )#/ 120) #check on linux '^'
      Mouse.wheel = 0
    end
    # Load the parameters of the scrollbar
    def load_parameters(max = nil)
      @position = 0
      @max = max ? max : @main_sprite.bitmap.height - @surface.height
      @max = 0 if @max < 0
      update_position(0)
    end
    # Update the position of the scrollbar and the scroll of the sprite
    # @param add_position [Integer] the position to add in y to the content rect of the sprite and the bar button
    def update_position(add_position)
      @position += add_position
      if @position < 0
        @position = 0
      elsif @position >= @max
        @position = @max
      end
      @sprite_stack[2].y = @scroll_min_y
      @sprite_stack[2].y += (@position * @scroll_delta_y) / @max if @max > 0
      unless @no_action
        @main_sprite.src_rect.y = @position
        @callback.call(@position) if @callback
      end
      return true
    end
    # Dispose the scrollbar
    def dispose
      sprite = nil
      @sprite_stack[3].bitmap.dispose
      @sprite_stack.each { |sprite| sprite.dispose }
    end
    # Change the click state of a button
    # @param sp [Sprite] the next sprite to unclick
    def unclick(sp = nil)
      return if sp and sp == @unclick
      @unclick.src_rect.y = 0
      @unclick.src_rect.x = 0
      @unclick = sp if sp
    end
  end
end
