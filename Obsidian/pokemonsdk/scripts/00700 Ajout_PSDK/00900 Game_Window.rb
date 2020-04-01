# Display a Window with the ability to zoom.
# @author Nuri Yuri
# @deprecated Don't use this otherwise your scripts will have issue once I removed this!
#   Use UI::Window instead !
class Game_Window
  include Text::Util
  # Width of the window
  # @return [Integer]
  attr_reader :width
  # Height of the window
  # @return [Integer]
  attr_reader :height
  # Rect of the cursor that define its x,y position and its dimensions
  # @return [Rect]
  attr_reader :cursor_rect
  # Opacity of the Window frame (0~255)
  # @return [Integer]
  attr_reader :back_opacity
  # Opacity of the window contents (0~255)
  # @return [Integer]
  attr_reader :contents_opacity
  # Global opacity of the Window (frame, contents, cursors) (0~255)
  # @return [Integer]
  attr_reader :opacity
  # Offset X of the contents
  # @return [Integer]
  attr_reader :ox
  # Offset Y of the contents
  # @return [Integer]
  attr_reader :oy
  # Bitmap that contain the basic frame of the Window
  # @return [Bitmap, nil]
  attr_reader :windowskin
  # Array that describe how the frame is defined on the windowskin.
  #   Defined this way : [frame_mid_x, frame_mid_y, frame_mid_width, frame_mid_height, contents_ox, contents_oy]
  #   frame_mid correspond to the tile in the center of the frame.
  # @return [Array(Integer, Integer, Integer, Integer, Integer, Integer)]
  attr_reader :window_builder
  # Bitmap of the pause_cursor, contains 4 frames 2 by 2
  # @return [Bitmap, nil]
  attr_reader :pauseskin
  # Bitmap of the cursor, contains only one frame
  # @return [Bitmap, nil]
  attr_reader :cursorskin
  # Indicate if the frame is draw by stretching it or repeating it (middle tiles)
  # @return [Boolean]
  #attr_accessor :stretch
  # Indicate if the pause sprite is shown or not
  # @return [Boolean]
  attr_accessor :pause
  # x coordinate of the pause sprite in the Window. If nil, the x coordinate is considered as the center of the window.
  # @return [Integer, nil]
  attr_accessor :pause_x
  # y coordinate of the pause sprite in the Window. If nil, the y coordinate is considered as the bottom of the window
  # @return [Integer, nil]
  attr_accessor :pause_y
  # Indicate if the cursor of the window is displayed.
  # @return [Boolean]
  attr_accessor :active
  # Change the font id of the window
  # @return [Integer]
  attr_accessor :font_id
  # Create a new Window
  # @param viewport [Viewport, nil] viewport where the window is shown.
  def initialize(viewport=nil)
    #>Sprite du back
    @window = Sprite.new(viewport)
    #>Dimensions
    @width = 0
    @height = 0
    #>Déplacements
    @ox = 0
    @oy = 0
    #>Opacité de la fenêtre (arrière)
    @back_opacity = 255
    @contents_opacity = 255
    @opacity = 255
    #>Définition du rect du curseur
    @cursor_rect = Rect.new(0,0,0,0)
    @___ori_rect = @cursor_rect.clone
    #>Attribut indiquant si on dessine en stretch ou pas
    @active = false
    @pause = false
    #>Tableau de construction de la fenêtre
    @window_builder = GameData::Windows::MessageWindow
    @windowskin = nil
    @cursorskin = nil
    @pauseskin = nil
    @__cac = 0
    @disposed = false
    init_text(0, self.viewport)
  end
  # Change the Window builder, redraw the frame if needed
  # @param v [Array(Integer, Integer, Integer, Integer, Integer, Integer)] the window builder descriptor
  def window_builder=(v)
    if(v.class==Array and v.size==6)
      @window_builder = v
      yuri_draw_window if @width>0 and @height>0
    end
  end
  # Update the zoom of every sprite on the Window (Zoom change)
  def reset_zoom
    @window.zoom = 1
    reset_cursor_pos if @cursor_sprite
    reset_pause_pos if @pause_sprite
  end
  # Update the window (pause animation, cursor animation etc...)
  def update
    @__cac += 1
    @__cac = 0 if @__cac >= 128
    if(@pause_sprite)
      @pause_sprite.visible = @pause && @window.visible
      if(@pauseskin)
        v = @__cac / 16
        w = @pauseskin.width / 2
        h = @pauseskin.height / 2
        @pause_sprite.src_rect.set(
          (v&0x01)==1 ? w : 0,
          (v&0x02)==2 ? h : 0,
          w, h)
      end
    end
    if(@cursor_sprite)
      if(@cursor_rect != @___ori_rect)
        @___ori_rect = @cursor_rect.clone
        reset_cursor_pos
      end
      v = @__cac
      if(v > 64)
        v -= 64
        @cursor_sprite.opacity=(@active ? 128+2*v : 128)*@opacity/255
      else
        @cursor_sprite.opacity=(@active ? 255-2*v : 128)*@opacity/255
      end
    end
  end
  # Change the cursorskin
  # @param v [Bitmap] the new cursorskin
  def cursorskin=(v)
    return if v.class != Bitmap and v != nil
    @cursorskin = v
    unless @cursor_sprite
      @cursor_sprite = Sprite.new(@window.viewport)
      @cursor_sprite.bitmap = @cursorskin
      @cursor_sprite.opacity = (@active ? 255 : 128) * @opacity
      @cursor_sprite.visible = @window.visible
      reset_cursor_pos
    end
  end
  # Change the pauseskin
  # @param v [Bitmap] the new pauseskin
  def pauseskin=(v)
    return if v.class != Bitmap and v != nil
    @pauseskin=v
    unless @pause_sprite
      @pause_sprite = Sprite.new(@window.viewport)
      @pause_sprite.bitmap = @pauseskin
      @pause_sprite.opacity = @opacity
      @pause_sprite.visible = @window.visible && @pause
      @pause_sprite.src_rect.set(0,0,@pauseskin.width/2,@pauseskin.height/2) if @pauseskin
      reset_pause_pos
    end
  end
  # Reset the position of the pause_cursor sprite
  # @!visibility private
  def reset_pause_pos
    return unless @pause_sprite
    sp = @pause_sprite
    sp.zoom = 1
    return unless @pauseskin
    pause_x = (@pause_x ? @pause_x : (@width-@pauseskin.width)/2)
    pause_y = (@pause_y ? @pause_y : @height-@pauseskin.height-2)
    sp.x = @window.x + pause_x
    sp.y = @window.y + pause_y
    sp.z = @window.z
  end
  private :reset_pause_pos
  # Reset the position of the cursor sprite
  # @!visibility private
  def reset_cursor_pos
    return unless @cursor_sprite
    sp = @cursor_sprite
    sp.x = @cursor_rect.x + @window_builder[4] + @window.x
    sp.y = @cursor_rect.y + @window_builder[5] + @window.y
    sp.z = @window.z
    if(sp.bitmap)
      sp.zoom_x = @cursor_rect.width.to_f / sp.bitmap.width
      sp.zoom_y = @cursor_rect.height.to_f / sp.bitmap.height
    end
    sp.visible = @window.visible && @active
  end
  private :reset_cursor_pos
  # X coordinate of the Window
  # @return [Integer]
  def x
    return @window.x
  end
  # Y coordinate of the Window
  # @return [Integer]
  def y
    return @window.y
  end
  # Z superiority of the Window
  # @return [Integer]
  def z
    return @window.z
  end
  # Change the X coordinate of the Window
  # @param v [Integer] the new x coordinate
  def x=(v)
    dx = v - @window.x
    @texts.each { |text| text.x += dx } if @text_viewport == @window.viewport
    @window.x = v
    @cursor_sprite.x = (@cursor_rect.x + @window_builder[4] + @window.x) if @cursor_sprite
    @pause_sprite.x = @window.x + (@pause_x ? @pause_x : (@width - @pause_sprite.bitmap.width) / 2) if(@pause_sprite and @pauseskin)
  end
  # Change the Y coordinate of the Window
  # @param v [Integer] the new y coordinate
  def y=(v)
    dy = v - @window.y
    @texts.each { |text| text.y += dy } if @text_viewport == @window.viewport
    @window.y = v
    @cursor_sprite.y = (@cursor_rect.y+@window_builder[5]+@window.y) if @cursor_sprite
    @pause_sprite.y = @window.y + (@pause_y ? @pause_y : @height - @pauseskin.height - 2) if(@pause_sprite and @pauseskin)
  end
  # Change the Z superiority of the Window
  # @param v [Integer] the new z superiority
  def z=(v)
    @window.z = v
    @texts.each { |text| text.z = v + 1 } if @text_viewport == @window.viewport
    @cursor_sprite.z = v if @cursor_sprite
    @pause_sprite.z = v if @pause_sprite
  end
  # Change the windowskin of the Window
  # @param v [Bitmap] the new windowskin of the window
  def windowskin=(v)
    return if v.class != Bitmap and v != nil
    @windowskin = v
    yuri_draw_window if @width > 0 and @height > 0
  end
  # Return the contents of the Window
  # @return [Bitmap, nil]
  def contents
    return @window.bitmap
  end
  # Return the viewport of the Window
  # @return [Viewport, nil]
  def viewport
    return @window.viewport
  end
  # Change the width of the Window
  # @param v [Integer] the new width of the window (>= 0)
  def width=(v)
    return if v<0
    @width = v
    yuri_draw_window if @width>0 and @height>0
  end
  # Change the height of the Window
  # @param v [Integer] the new height of the window (>= 0)
  def height=(v)
    return if v<0
    @height = v
    yuri_draw_window if @width>0 and @height>0
  end
  # Change the cursor_rect
  # @param v [Rect] the new rect of the cursor
  def cursor_rect=(v)
    @cursor_rect=v if v.class==Rect
  end
  # Tells if the Window is visible or not
  # @return [Boolean]
  def visible
    return @window.visible
  end
  # Change the visible state of the Window
  # @param v [Boolean] the new visible state of the window
  def visible=(v)
    @window.visible = v
    @cursor_sprite.visible = v if @cursor_sprite
    text_each { |text| text.visible = v }
  end
  # Change the global opacity of the window
  # @param v [Integer] new opacity between 0 and 255
  def opacity=(v)
    v=0 if v<0
    v=255 if v>255
    @window.opacity = @back_opacity * v / 255
    @opacity = v
    v = @contents_opacity * v / 255
    text_each { |text| text.opacity = v }
  end
  # Change the frame opacity of the window
  # @param v [Integer] new opacity between 0 and 255
  def back_opacity=(v)
    v=0 if v<0
    v=255 if v>255
    @back_opacity = v
    @window.opacity = @opacity * v /255
  end
  # Change the contents opacity of the window
  # @param v [Integer] new opacity between 0 and 255
  def contents_opacity=(v)
    v=0 if v<0
    v=255 if v>255
    @contents_opacity = v
    v = @opacity * v / 255
    text_each { |text| text.opacity = v }
  end
  # Change the contents origin x
  # @param v [Integer]
  def ox=(v)
    return
    @ox = v.to_i
    yuri_repos_window if @width>0 and @height>0
  end
  # Change the contents origin y
  # @param v [Integer]
  def oy=(v)
    return
    @oy = v.to_i
    yuri_repos_window if @width>0 and @height>0
  end
  # Dispose every sprite of the window
  def dispose
    return if @disposed
    @window.bitmap.dispose if @window.bitmap
    @pause_sprite.dispose if @pause_sprite
    @cursor_sprite.dispose if @cursor_sprite
    @texts.each { |text| text.dispose }
    @texts.clear
    @text_viewport.dispose if @text_viewport != @window.viewport
    @window.dispose
    @disposed = true
  end
  # Check if the window is disposed
  def disposed?
    return @disposed
  end

  private
  # Draw the window
  def yuri_draw_window
    yuri_repos_window
    @window.bitmap.dispose if @window.bitmap
    @window.bitmap = nil
    return unless @windowskin
    @window.bitmap = Bitmap.new(@width,@height)
    @window.src_rect.set(0,0,@width,@height)
    yuri_draw_blt_window
    @window.bitmap.update
  end
  # Repeat draw of the frame
  def yuri_draw_blt_window
    xm=@window_builder[0]
    ym=@window_builder[1]
    wm=@window_builder[2]
    hm=@window_builder[3]
    sbmp=@windowskin
    bmp=@window.bitmap
    ws=sbmp.width
    hs=sbmp.height
    wt=@width
    ht=@height
    rect=Rect.new(0,0,0,0)
    #>Calcul et équilibrage du dessin sur la largeur
    w3=ws-xm-wm
    w1=xm
    delta_w=wt-w1-w3
    if(delta_w<0)
      delta_w/=2
      w1+=delta_w
      w3+=delta_w
      delta_w=wt-w1-w3
    end
    nb2=delta_w/wm
    delta_w=delta_w-(nb2*wm) #Le chouilla qui reste sur le milieu
    #>Calcul et équilibrage du dessin sur la hauteur
    h1=ym
    h7=hs-hm-ym
    delta_h=ht-h1-h7
    if(delta_h<0)
      delta_h/=2
      h1+=delta_h
      h7+=delta_h
      delta_h=ht-h1-h7
    end
    nb4=delta_h/hm
    delta_h=delta_h-(nb4*hm)
    #>Dessin des 4 bords
    #[ 1, ..., ...] / [ ..., ..., ...] / [ ..., ..., ...]
    rect.set(0,0,w1,h1)
    bmp.blt(0,0,sbmp,rect)
    #[ ..., ..., 3] / [ ..., ..., ...] / [ ..., ..., ...]
    rect.set(ws-w3,0,w3,h1)
    bmp.blt(wt-w3,0,sbmp,rect)
    #[ ..., ..., ...] / [ ..., ..., ...] / [ 7, ..., ...]
    rect.set(0,hs-h7,w1,h7)
    bmp.blt(0,ht-h7,sbmp,rect)
    #[ ..., ..., ...] / [ ..., ..., ...] / [ ..., ..., 9]
    rect.set(ws-w3,hs-h7,w3,h7)
    bmp.blt(wt-w3,ht-h7,sbmp,rect)
    #>Dessin des contours de la fenêtre
    # [ ..., 2, ...] / [ ..., ..., ...] / [ ..., ..., ...]
    ax=w1
    rect.set(xm,0,wm,h1)
    nb2.times do
      bmp.blt(ax,0,sbmp,rect)
      ax+=wm
    end
    rect.set(xm,0,delta_w,h1)
    bmp.blt(ax,0,sbmp,rect) if delta_w>0
    # [ ..., ..., ...] / [ 4, ..., ...] / [ ..., ..., ...]
    ay=h1
    rect.set(0,ym,w1,hm)
    nb4.times do 
      bmp.blt(0,ay,sbmp,rect)
      ay+=hm
    end
    rect.set(0,ym,w1,delta_h)
    bmp.blt(0,ay,sbmp,rect) if delta_h>0
    # [ ..., ..., ...] / [ ..., ..., 6] / [ ..., ..., ...]
    ax=wt-w3
    ay=h1
    rect.set(ws-w3,ym,w3,hm)
    nb4.times do
      bmp.blt(ax,ay,sbmp,rect)
      ay+=hm
    end
    rect.set(ws-w3,ym,w3,delta_h)
    bmp.blt(ax,ay,sbmp,rect) if delta_h>0
    # [ ..., ..., ...] / [ ..., ..., ...] / [ ..., 8, ...]
    ax=w1
    ay=ht-h7
    rect.set(xm,hs-h7,wm,h7)
    nb2.times do
      bmp.blt(ax,ay,sbmp,rect)
      ax+=wm
    end
    rect.set(xm,hs-h7,delta_w,h7)
    bmp.blt(ax,ay,sbmp,rect) if delta_w>0
    #>Dessin de l'intérieur
    # [ ..., ..., ...] / [ ..., 5|m , ...] / [ ..., ..., ...]
    ax=w1
    ay=h1
    rect.set(xm,ym,wm,hm)
    nb2.times do
      nb4.times do
        bmp.blt(ax,ay,sbmp,rect)
        ay+=hm
      end
      ax+=wm
      ay=h1
    end
    ay+=(hm*nb4)
    if(delta_w>0 and delta_h>0)
      rect.set(xm,ym,delta_w,delta_h)
      bmp.blt(ax,ay,sbmp,rect)
    end
    if(delta_h>0)
      ax=w1
      rect.set(xm,ym,wm,delta_h)
      nb2.times do
        bmp.blt(ax,ay,sbmp,rect)
        ax+=wm
      end
    end
    if(delta_w>0)
      ay=h1
      rect.set(xm,ym,delta_w,hm)
      nb4.times do
        bmp.blt(ax,ay,sbmp,rect)
        ay+=hm
      end
    end
  end
  # Adjust the contents position in the window
  def yuri_repos_window
    oox = @ox
    ooy = @oy
    @ox = @window_builder[4]
    @oy = @window_builder[5]
    oox = @ox - oox
    ooy = @oy - ooy
    if @text_viewport == @window.viewport
      if(oox != 0 or ooy != 0)
        @texts.each do |text|
          text.set_position(text.x + oox, text.y + ooy)
        end
      end
    end
    return
    @contents.ox=-ox
    @contents.oy=-oy
    rect=@contents.src_rect
    rect.set(@ox, @oy, @width-ox*2,@height-oy*2) if(rect)
  end
end
