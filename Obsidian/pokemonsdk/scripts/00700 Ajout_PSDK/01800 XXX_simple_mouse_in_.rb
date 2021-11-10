class Sprite
  # Detect if the mouse is in the sprite (without rotation and stuff like that)
  # @param mouse_x [Integer] the mouse x position on the screen
  # @param mouse_y [Integer] the mouse y position on the screen
  # @return [Boolean]
  # @author Nuri Yuri
  def simple_mouse_in?(mouse_x = Mouse.x, mouse_y = Mouse.y)
    if viewport
      return false unless viewport.simple_mouse_in?(mouse_x, mouse_y)
      mouse_x, mouse_y = viewport.translate_mouse_coords(mouse_x, mouse_y)
    end
    bx = x
    by = y
    return false if mouse_x < bx || mouse_y < by
    bx += src_rect.width
    by += src_rect.height
    return false if mouse_x >= bx || mouse_y >= by
    true
  end

  # Detect if the mouse is in the sprite (without rotation)
  # @param mouse_x [Integer] the mouse x position on the screen
  # @param mouse_y [Integer] the mouse y position on the screen
  # @return [Boolean]
  # @author Nuri Yuri
  def mouse_in?(mouse_x = Mouse.x, mouse_y = Mouse.y)
    if viewport
      return false unless viewport.simple_mouse_in?(mouse_x, mouse_y)
      mouse_x, mouse_y = viewport.translate_mouse_coords(mouse_x, mouse_y)
    end
    bx = x - ox * (zx = zoom_x)
    by = y - oy * (zy = zoom_y)
    return false if mouse_x < bx || mouse_y < by
    bx += src_rect.width * zx
    by += src_rect.height * zy
    return false if mouse_x >= bx || mouse_y >= by
    true
  end

  # Convert mouse coordinate on the screen to mouse coordinates on the sprite
  # @param mouse_x [Integer] the mouse x position on the screen
  # @param mouse_y [Integer] the mouse y position on the screen
  # @return [Array(Integer, Integer)] the mouse coordinates on the sprite
  # @author Nuri Yuri
  def translate_mouse_coords(mouse_x = Mouse.x, mouse_y = Mouse.y)
    mouse_x, mouse_y = viewport.translate_mouse_coords(mouse_x, mouse_y) if viewport
    mouse_x -= x
    mouse_y -= y
    rect = src_rect
    mouse_x += rect.x
    mouse_y += rect.y
    return mouse_x, mouse_y
  end
end

class Text
  # Detect if the mouse is in the sprite (without rotation and stuff like that)
  # @param mouse_x [Integer] the mouse x position on the screen
  # @param mouse_y [Integer] the mouse y position on the screen
  # @return [Boolean]
  # @author Nuri Yuri
  def simple_mouse_in?(mouse_x = Mouse.x, mouse_y = Mouse.y)
    if viewport
      return false unless viewport.simple_mouse_in?(mouse_x, mouse_y)
      mouse_x, mouse_y = viewport.translate_mouse_coords(mouse_x, mouse_y)
    end
    bx = x
    by = y
    return false if mouse_x < bx || mouse_y < by
    bx += width
    by += height
    return false if mouse_x >= bx || mouse_y >= by
    true
  end

  # Convert mouse coordinate on the screen to mouse coordinates on the sprite
  # @param mouse_x [Integer] the mouse x position on the screen
  # @param mouse_y [Integer] the mouse y position on the screen
  # @return [Array(Integer, Integer)] the mouse coordinates on the sprite
  # @author Nuri Yuri
  def translate_mouse_coords(mouse_x = Mouse.x, mouse_y = Mouse.y)
    mouse_x, mouse_y = viewport.translate_mouse_coords(mouse_x, mouse_y) if viewport
    mouse_x -= x
    mouse_y -= y
    return mouse_x, mouse_y
  end
end

class Viewport
  # Detect if the mouse is in the sprite (without rotation and stuff like that)
  # @param mouse_x [Integer] the mouse x position on the screen
  # @param mouse_y [Integer] the mouse y position on the screen
  # @return [Boolean]
  # @author Nuri Yuri
  def simple_mouse_in?(mouse_x = Mouse.x, mouse_y = Mouse.y)
    vp_rect = rect
    if vp_rect.x <= mouse_x && (vp_rect.x + vp_rect.width) > mouse_x &&
        vp_rect.y <= mouse_y && (vp_rect.y + vp_rect.height) > mouse_y
      return true
    end
    return false
  end

  # Convert mouse coordinate on the screen to mouse coordinates on the sprite
  # @param mouse_x [Integer] the mouse x position on the screen
  # @param mouse_y [Integer] the mouse y position on the screen
  # @return [Array(Integer, Integer)] the mouse coordinates on the sprite
  # @author Nuri Yuri
  def translate_mouse_coords(mouse_x = Mouse.x, mouse_y = Mouse.y)
    vp_rect = rect
    return mouse_x - vp_rect.x + ox, mouse_y - vp_rect.y + oy
  end
end

class Window
  # Detect if the mouse is in the window
  # @param mouse_x [Integer] the mouse x position on the screen
  # @param mouse_y [Integer] the mouse y position on the screen
  # @return [Boolean]
  # @author Nuri Yuri
  def simple_mouse_in?(mouse_x = Mouse.x, mouse_y = Mouse.y)
    if viewport
      return false unless viewport.simple_mouse_in?(mouse_x, mouse_y)
      mouse_x, mouse_y = viewport.translate_mouse_coords(mouse_x, mouse_y)
    end
    bx = x
    by = y
    return false if mouse_x < bx || mouse_y < by
    bx += width
    by += height
    return false if mouse_x >= bx || mouse_y >= by
    true
  end

  # Convert mouse coordinate on the screen to mouse coordinates on the window
  # @param mouse_x [Integer] the mouse x position on the screen
  # @param mouse_y [Integer] the mouse y position on the screen
  # @return [Array(Integer, Integer)] the mouse coordinates on the window
  # @author Nuri Yuri
  def translate_mouse_coords(mouse_x = Mouse.x, mouse_y = Mouse.y)
    if viewport
      mouse_x, mouse_y = viewport.translate_mouse_coords(mouse_x, mouse_y)
    end
    rect = self.rect
    mouse_x -= rect.x - ox
    mouse_y -= rect.y - oy
    return mouse_x, mouse_y
  end
end
