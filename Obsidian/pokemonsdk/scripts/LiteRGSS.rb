# LiteRGSS namespace
#
# It contains every LiteRGSS classes and modules
module LiteRGSS
  # Error triggered by various functions for some reasons
  Error = StandardError.new
  # Class that defines a rectangular surface of a Graphical element
  class Rect
    # @!attribute [rw] x
    #   @return [Integer] x position of the surface
    # @!attribute [rw] y
    #   @return [Integer] y position of the surface
    # @!attribute [rw] width
    #   @return [Integer] width of the surface
    # @!attribute [rw] height
    #   @return [Integer] height of the surface
    # @!method self.new(x, y, width, height)
    #   Create a new surface
    #   @param x [Integer] x position of the surface
    #   @param y [Integer] y position of the surface
    #   @param width [Integer] width of the surface
    #   @param height [Integer] height of the surface
    # @!method set(x, y = nil, width = nil, height = nil)
    #   Set the parameters of the surface
    #   @param x [Integer, nil] x position of the surface
    #   @param y [Integer, nil] y position of the surface
    #   @param width [Integer, nil] width of the surface
    #   @param height [Integer, nil] height of the surface
    #   @return [self]
    # @!method to_s
    #   Convert the rect to a string that can be shown to the user
    #   @return [String] (x, y, width, height)
    # @!method inspect
    #   Convert the rect to a string that can be shown to the user
    #   @return [String] (x, y, width, height)
    # @!method empty
    #   Set all the rect coordinates to 0
    #   @return [self]
  end
  # Class that describes RGBA colors in integer scale (0~255)
  class Color
    # @!attribute [rw] red
    #   @return [Integer] The red component of the color
    # @!attribute [rw] green
    #   @return [Integer] The green component of the color
    # @!attribute [rw] blue
    #   @return [Integer] The blue component of the color
    # @!attribute [rw] alpha
    #   @return [Integer] The alpha opacity of the color
    # @!method self.new(red, green, blue, alpha = 255)
    #   Create a new color
    #   @param red [Integer, nil] between 0 and 255
    #   @param green [Integer, nil] between 0 and 255
    #   @param blue [Integer, nil] between 0 and 255
    #   @param alpha [Integer, nil]  between 0 and 255 (default : 255)
    # @!method set(red, green = nil, blue = nil, alpha = nil)
    #   Set the color parameters
    #   @param red [Integer, nil] between 0 and 255
    #   @param green [Integer, nil] between 0 and 255
    #   @param blue [Integer, nil] between 0 and 255
    #   @param alpha [Integer, nil]  between 0 and 255
    #   @return [self]
    # @!method to_s
    #   Convert the color to a string that can be shown to the user
    #   @return [String] (r, g, b, a)
    # @!method inspect
    #   Convert the color to a string that can be shown to the user
    #   @return [String] (r, g, b, a)
  end
  # Class that describe tones (added/modified colors to the surface)
  class Tone
    # @!attribute [rw] red
    #   @return [Integer] The red component of the tone
    # @!attribute [rw] green
    #   @return [Integer] The green component of the tone
    # @!attribute [rw] blue
    #   @return [Integer] The blue component of the tone
    # @!attribute [rw] gray
    #   @return [Integer] The gray modifier of the tone (255 => grayscale)
    # @!method self.new(red, green, blue, gray = 0)
    #   Create a new tone
    #   @param red [Integer, nil] between -255 and 255
    #   @param green [Integer, nil] between -255 and 255
    #   @param blue [Integer, nil] between -255 and 255
    #   @param gray [Integer, nil]  between 0 and 255
    # @!method set(red, green = nil, blue = nil, gray = nil)
    #   Set the tone parameters
    #   @param red [Integer, nil] between -255 and 255
    #   @param green [Integer, nil] between -255 and 255
    #   @param blue [Integer, nil] between -255 and 255
    #   @param gray [Integer, nil]  between 0 and 255
    #   @return [self]
    # @!method to_s
    #   Convert the tone to a string that can be shown to the user
    #   @return [String] (r, g, b, a)
    # @!method inspect
    #   Convert the tone to a string that can be shown to the user
    #   @return [String] (r, g, b, a)
  end
  # Class of all the element that can be disposed
  class Disposable
    # @!method dispose
    #   Dispose the element (and free its memory)
    #   @return [self]
    # @!method disposed?
    #   Tell if the element was disposed
    #   @return [Boolean]
  end
  # Class of all the element that can be drawn in a Viewport or the Graphic display
  class Drawable < Disposable
  end
  # Class that stores an image loaded from file or memory into the VRAM
  class Bitmap < Disposable
    # @!method self.new(filename_or_memory, from_memory = nil)
    #   Create a new texture from existing texture data (PNG)
    #   @param filename_or_memory [String] texture data filename or content
    #   @param from_memory [Boolean] if filename_or_memory is content 
    # @!method self.new(width, height)
    #   Create a new empty texture
    #   @param width [Integer] width of the new texture
    #   @param height [Integer] height of the new texture
    # @!attribute [r] width
    #   @return [Integer] Returns the width of the texture
    # @!attribute [r] height
    #   @return [Integer] Returns the heigth of the texture
    # @!attribute [r] rect
    #   @return [Rect] Returns the surface of the texture (0, 0, width, height)
    # @!method update
    #   update the content of the texture if some illegal drawing were made over it
    #   @return [self]
    #   @deprecated Please do not use this method, draw your stuff in a Image first and then copy the content to the texture
    # @!method to_png
    #   Convert bitmap to PNG
    #   @return [String, nil] contents of the PNG, nil if couldn't be converted to PNG
    # @!method to_png_file(filename)
    #   Save the bitmap to a PNG file
    #   @param filename [String] Name of the PNG file
    #   @return [Boolean] success of the operation
  end
  # Class that is dedicated to perform Image operation in Memory before displaying those operations inside a texture (Bitmap)
  class Image < Disposable
    # @!method self.new(filename_or_memory, from_memory = nil)
    #   Create a new image from existing image data (PNG)
    #   @param filename_or_memory [String] image data filename or content
    #   @param from_memory [Boolean] if filename_or_memory is content
    # @!method self.new(width, height)
    #   Create a new empty image with dimensions
    #   @param width [Integer]
    #   @param height [Integer]
    # @!attribute [r] width
    #   @return [Integer] Returns the width of the image
    # @!attribute [r] height
    #   @return [Integer] Returns the heigth of the image
    # @!attribute [r] rect
    #   @return [Rect] Returns the surface of the image (0, 0, width, height)
    # @!method copy_to_bitmap(bitmap)
    #   Copy the image content to the bitmap (Bitmap must be the same size of the image)
    #   @param bitmap [Bitmap]
    #   @return [self]
    # @!method blt(x, y, source, source_rect)
    #   Blit an other image to this image (process alpha)
    #   @param x [Integer] dest x coordinate
    #   @param y [Integer] dest y coordinate
    #   @param source [Image] image containing the copied pixels
    #   @param source_rect [Rect] surface of the source containing the copied pixels
    #   @return [self]
    # @!method blt!(x, y, source, source_rect)
    #   Blit an other image to this image (replace the pixels)
    #   @param x [Integer] dest x coordinate
    #   @param y [Integer] dest y coordinate
    #   @param source [Image] image containing the copied pixels
    #   @param source_rect [Rect] surface of the source containing the copied pixels
    #   @return [self]
    # @!method stretch_blt(dest_rect, source, source_rect)
    #   Stretch blit an other image to this image (process alpha)
    #   @param dest_rect [Rect] surface of the current image where to copy pixels
    #   @param source [Image] image containing the copied pixels
    #   @param source_rect [Rect] surface of the source containing the copied pixels
    #   @return [self]
    # @!method stretch_blt!(dest_rect, source, source_rect)
    #   Stretch blit an other image to this image (replace the pixels)
    #   @param dest_rect [Rect] surface of the current image where to copy pixels
    #   @param source [Image] image containing the copied pixels
    #   @param source_rect [Rect] surface of the source containing the copied pixels
    #   @return [self]
    # @!method clear_rect(x, y, width, height)
    #   Clear a portion of the image
    #   @param x [Integer] left corner coordinate
    #   @param y [Integer] top corner coordinate
    #   @param width [Integer] width of the cleared surface
    #   @param height [Integer] height of the cleared surface
    #   @return [self]
    # @!method fill_rect(x, y, width, height, color)
    #   Fill a portion of the image with a color
    #   @param x [Integer] left corner coordinate
    #   @param y [Integer] top corner coordinate
    #   @param width [Integer] width of the filled surface
    #   @param height [Integer] height of the filled surface
    #   @param color [Color] color to fill
    # @!method get_pixel(x, y)
    #   Get a pixel color
    #   @param x [Integer] x coordinate of the pixel
    #   @param y [Integer] y coordinate of the pixel
    #   @return [Color, nil] nil means x,y is outside of the Image surface
    # @!method get_pixel_alpha(x, y)
    #   Get a pixel alpha
    #   @param x [Integer] x coordinate of the pixel
    #   @param y [Integer] y coordinate of the pixel
    #   @return [Integer, 0]
    # @!method set_pixel(x, y, color)
    #   Set a pixel color
    #   @param x [Integer] x coordinate of the pixel
    #   @param y [Integer] y coordinate of the pixel
    #   @param color [Color] new color of the pixel
    #   @return [self]
    # @!method create_mask(color, alpha)
    #   Change the alpha of all the pixel that match the input color
    #   @param color [Color] color to match
    #   @param alpha [Integer] new apha value of the pixel that match color
    # @!method to_png
    #   Convert Image to PNG
    #   @return [String, nil] contents of the PNG, nil if couldn't be converted to PNG
    # @!method to_png_file(filename)
    #   Save the Image to a PNG file
    #   @param filename [String] Name of the PNG file
    #   @return [Boolean] success of the operation
  end
  # Class that describes a surface of the screen where texts and sprites are shown (with some global effect)
  class Viewport < Disposable
    # @!attribute [rw] rect
    #   @return [Rect] The surface of the viewport on the screen
    # @!attribute [rw] ox
    #   @return [Integer] The offset x of the viewport's contents
    # @!attribute [rw] oy
    #   @return [Integer] The offset y of the viewport's contents
    # @!attribute [rw] visible
    #   @return [Boolean] Viewport content visibility
    # @!attribute [rw] z
    #   @return [Numeric] The viewport z property
    # @!attribute [rw] angle
    #   @return [Integer] Angle of the viewport contents
    # @!attribute [rw] zoom
    #   @return [Integer] Zoom of the viewport contents
    #   @note Input is inverse of output due to internal logic (zoom=2 will make .zoom return 0.5)
    #     what matters is input, if you set 2, pixels will be 2x2
    # @!attribute blendmode
    #   @return [Shader, BlendMode] Blend Mode of the viewport (can be specified in the shader)
    # @!attribute shader
    #   @return [Shader, BlendMode] Shader of the viewport (include the BlendMode properties)
    # @!method self.new(window, x, y, width, height)
    #   Create a new Viewport
    #   @param window [DisplayWindow] window in which the viewport is shown
    #   @param x [Integer] x position of the surface
    #   @param y [Integer] y position of the surface
    #   @param width [Integer] width of the surface
    #   @param height [Integer] height of the surface
    # @!attribute [r] __index__
    #   @return [Integer] Return the viewport "index" (used to know if the viewport has been created after an other sprite or viewport when z are the same
    # @!method snap_to_bitmap
    #   Return a snapshot of the viewport
    #   @return [Bitmap]
    # @!method sort_z
    #   Sort all the elements inside the viewport according to their z index
    #   @return [self]
  end
  # Class that describe a sprite shown on the screen or inside a viewport
  # @note Sprites cannot be saved, loaded from file nor cloned in the memory
  class Sprite < Drawable
    # @!method self.new(viewport)
    #   Create a new Sprite
    #   @param viewport [Viewport, Window] the viewport in which the sprite is shown, can be a Window
    # @!method set_position(x, y)
    #   Define the position of the sprite
    #   @param x [Numeric]
    #   @param y [Numeric]
    #   @return [self]
    # @!method set_origin(ox, oy)
    #   Define the origine of the sprite (inside the texture)
    #   @param ox [Numeric]
    #   @param oy [Numeric]
    #   @return [self]
    # @!attribute [w] zoom
    #   @return [Numeric] Define the zoom of the sprite when shown on screen
    # @!attribute [r] __index__
    #   @return [Integer] Return the sprite index to know if it has been created before an other sprite (in the same viewport)
    # @!attribute [rw] bitmap
    #   @return [Bitmap, nil] texture shown by the sprite
    # @!attribute [rw] src_rect
    #   @return [Rect] Surface of the sprite's texture show on the screen
    # @!attribute [rw] visible
    #   @return [Boolean] If the sprite is shown or not
    # @!attribute [rw] x
    #   @return [Numeric] X coordinate of the sprite
    # @!attribute [rw] y
    #   @return [Numeric] Y coordinate of the sprite
    # @!attribute [rw] z
    #   @return [Numeric] The z Coordinate of the sprite (for sorting)
    # @!attribute [rw] ox
    #   @return [Numeric] The x coordinate of the pixel inside the texture that is shown at x coordinate of the sprite
    # @!attribute [rw] oy
    #   @return [Numeric] The y coordinate of the pixel inside the texture that is shown at y coordinate of the sprite
    # @!attribute [rw] angle
    #   @return [Numeric] The rotation of the sprite in degree
    # @!attribute [rw] zoom_x
    #   @return [Numeric] The zoom scale in width axis of the sprite
    # @!attribute [rw] zoom_y
    #   @return [Numeric] The zoom scale in height axis of the sprite
    # @!attribute [rw] opacity
    #   @return [Numeric] The opacity of the sprite
    # @!attribute [rw] viewport
    #   @return [Viewport, Window, nil] The sprite viewport
    # @!attribute [rw] mirror
    #   @return [Boolean] If the sprite texture is mirrored
    # @!attribute [r] width
    #   @return [Integer] Return the sprite width
    # @!attribute [r] height
    #   @return [Integer] Return the sprite height
  end
  # Class that describes a text shown on the screen or inside a viewport
  # @note Text cannot be saved, loaded from file nor cloned in the memory
  class Text < Drawable
    # @!method self.new(font_id, viewport, x, y, width, height, str, align = 0, outlinesize = nil, color_id = nil, size_id = nil)
    #   Create a new Text
    #   @param font_id [Integer] the id of the font to use to draw the text (loads the size and default colors from that)
    #   @param viewport [Viewport, Window] the viewport in which the text is shown, can be a Window
    #   @param x [Integer] the x coordinate of the text surface
    #   @param y [Integer] the y coordinate of the text surface
    #   @param width [Integer] the width of the text surface
    #   @param height [Integer] the height of the text surface
    #   @param str [String] the text shown by this object
    #   @param align [0, 1, 2] the align of the text in its surface (best effort => no resize), 0 = left, 1 = center, 2 = right
    #   @param outlinesize [Integer, nil] the size of the text outline
    #   @param color_id [Integer, nil] ID of the color took from Fonts
    #   @param size_id [Integer, nil] ID of the size took from Fonts
    # @!method set_position(x, y)
    #   Define the position of the text
    #   @param x [Numeric]
    #   @param y [Numeric]
    #   @return [self]
    # @!attribute [rw] x
    #   @return [Numeric] The x coordinate of the text surface
    # @!attribute [rw] y
    #   @return [Numeric] The y coordinate of the text surface
    # @!attribute [rw] width
    #   @return [Numeric] The width of the text surface
    # @!attribute [rw] height
    #   @return [Numeric] The height of the text surface
    # @!attribute [rw] outline_thickness
    #   @return [Integer] The size of the text outline
    # @!attribute [rw] size
    #   @return [Integer] The font size of the text
    # @!attribute [rw] align
    #   @return [Integer] The alignment of the text (0 = left, 1 = center, 2 = right)
    # @!attribute [rw] fill_color
    #   @return [Color] The inside color of the text
    # @!attribute [rw] outline_color
    #   @return [Color] The color of the outline
    # @!method load_color(font_id)
    #   Load a color from a font_id
    #   @param font_id [Integer] id of the font where to load the colors
    #   @return [self]
    # @!attribute [rw] text
    #   @return [String] Text shown by this Object
    # @!attribute [rw] visible
    #   @return [Boolean] If the Text is visible
    # @!attribute [rw] draw_shadow
    #   @return [Boolean] If the text is drawn as in Pokemon DPP / RSE / HGSS / BW (with shadow)
    # @!attribute [rw] nchar_draw
    #   @return [Integer] The number of character the object should draw
    # @!attribute [r] real_width
    #   @return [Integer] Return the real width of the text
    # @!attribute [rw] opacity
    #   @return [Integer] Opacity of the text
    # @!method text_width(text)
    #   Return the width of the given string if drawn by this Text object
    #   @param text [String]
    #   @return [Integer]
    # @!attribute [rw] z
    #   @return [Numeric] The Text z property
    # @!attribute [r] __index__
    #   @return [Integer] Return the text index to know if it has been created before an other sprite/text/viewport in the same viewport
    # @!attribute [r] viewport
    #   @return [Viewport, Window] Return the Text viewport
    # @!attribute [rw] italic
    #   @return [Boolean] If the text should be shown in italic
    # @!attribute [rw] bold
    #   @return [Boolean] If the text should be shown in bold
  end
  # Class used to show a Window object on screen.
  #
  # A Window is an object that has a frame (built from #window_builder and #windowskin) and some contents that can be Sprites or Texts.
  class Window < Drawable
    # @!method self.new(viewport)
    #   Create a new Window
    #   @param viewport [Viewport]
    # @!method update
    #   Update the iner Window Animation (pause sprite & cursor sprite)
    #   @return [self]
    # @!method lock
    #   Lock the window vertice calculation (background)
    #   @return [self]
    # @!method unlock
    #   Unlock the window vertice calculation and force the calculation at the same time (background)
    #   @return [self]
    # @!method locked?
    #   Tell if the window vertice caculation is locked or not
    #   @return [Boolean]
    # @!attribute [r] viewport
    #   @return [Viewport] viewport in which the Window is shown
    # @!attribute [rw] windowskin
    #   @return [Bitmap] Windowskin used to draw the Window frame
    # @!attribute [rw] width
    #   @return [Integer] Width of the Window
    # @!attribute [rw] height
    #   @return [Integer] Height of the Window
    # @!method set_size(width, height)
    #   Change the size of the window
    #   @param width [Integer] new width
    #   @param height [Integer] new height
    #   @return [self]
    # @!attribute [rw] window_builder
    #   @return [Array(Integer, Integer, Integer, Integer, Interger, Integer)] the window builder of the Window
    #   @note Array contain the 6 following values : [middle_tile_x, middle_tile_y, middle_tile_width, middle_tile_height, contents_border_x, contents_border_y, cb_right, cb_botton]
    #         The frame is calculated from the 4 first value, the 2 last values gives the offset in x/y between the border of the frame and the border of the contents.
    # @!attribute [rw] x
    #   @return [Integer] X position of the Window
    # @!attribute [rw] y
    #   @return [Integer] Y position of the Window
    # @!method set_position(x, y)
    #   Change the position of the window on screen
    #   @param x [Integer] new x position
    #   @param y [Integer] new y position
    #   @return [self]
    # @!attribute [rw] z
    #   @return [Integer] z order position of the Window in the Viewport/Graphics
    # @!attribute [rw] ox
    #   @return [Integer] origin x of the contents of the Window in the Window View
    # @!attribute [rw] oy
    #   @return [Integer] origin y of the contents of the Window in the Window View
    # @!method set_origin(ox, oy)
    #   Change the contents origin x/y in the Window View
    #   @param ox [Integer]
    #   @param oy [Integer]
    #   @return [self]
    # @!attribute [rw] cursor_rect
    #   @return [Rect] cursor rect giving the coordinate of the cursor and the size of the cursor (to perform zoom operations)
    # @!attribute [rw] cursorskin
    #   @return [Bitmap, nil] cursor texture used to show the cursor when the Window is active
    # @!attribute [rw] pauseskin
    #   @return [Bitmap, nil] Bitmap used to show the pause animation (there's 4 cells organized in a 2x2 matrix to show the pause animation)
    # @!attribute [rw] pause
    #   @return [Boolean] if the pause animation is shown (message)
    # @!attribute [rw] pause_x
    #   @return [Integer, nil] x coordinate of the pause sprite in the Window (if nil, middle of the window)
    # @!attribute [rw] pause_y
    #   @return [Integer, nil] y coordinate of the pause sprite in the Window (if nil, bottom of the window)
    # @!attribute [rw] active
    #   @return [Boolean] if the Window show the cursor
    # @!attribute [rw] stretch
    #   @return [Boolean] if the Window draw the frame by stretching the border (true) or by repeating the middle border tiles (false)
    # @!attribute [rw] opacity
    #   @return [Integer] opacity of the whole Window
    # @!attribute [rw] back_opacity
    #   @return [Integer] opacity of the Window frame
    # @!attribute [rw] contents_opacity
    #   @return [Integer] opacity of the Window contents (sprites/texts)
    #   @note It erase the opacity attribute of the texts/sprites
    # @!attribute [r] rect
    #   @return [Rect] rect corresponding to the view of the Window (Viewport compatibility)
    # @!attribute [rw] visible
    #   @return [Boolean] if the window is visible or not
    # @!attribute [r] __index__
    #   @return [Integer] internal index of the Window in the Viewport stack when it was created
  end
  # Class allowing to draw Shapes in a viewport
  class Shape < Drawable
    # Constant telling the shape to draw a circle
    CIRCLE = :circle
    # Constant telling the shape to draw a convex shape
    CONVEX = :convex
    # Constant telling the shape to draw a rectangle
    RECTANGLE = :rectangle
    # @!method self.new(viewport, type, radius, num_pts)
    #   Create a new Circle shape
    #   @param viewport [Viewport] viewport in which the shape is shown
    #   @param type [Symbol] must be :circle
    #   @param radius [Numeric] radius of the circle (note : the circle is show from it's top left box corner and not its center)
    #   @param num_pts [Integer] number of points to use in order to draw the circle shape
    # @!method self.new(viewport, type, num_pts = 4)
    #   Create a new Convex shape
    #   @param viewport [Viewport] viewport in which the shape is shown
    #   @param type [Symbol] must be :convex
    #   @param num_pts [Integer] number of points to use in order to draw the convex shape
    # @!method self.new(viewport, type, width, height)
    #   Create a new Rectangle shape
    #   @param viewport [Viewport] viewport in which the shape is shown
    #   @param type [Symbol] must be :rectangle
    #   @param width [Integer] width of the rectangle
    #   @param height [Integer] height of the rectangle
    # @!attribute [rw] bitmap
    #   @return [Bitmap, nil] texture used to make a specific drawing inside the shape (bitmap is show inside the border of the shape)
    # @!attribute [rw] src_rect
    #   @return [Rect] source rect used to tell which part of the bitmap is shown in the shape
    # @!attribute [rw] x
    #   @return [Integer] x coordinate of the shape in the viewport
    # @!attribute [rw] y
    #   @return [Integer] y coordinate of the shape in the viewport
    # @!method set_position(x, y)
    #   Set the new coordinate of the shape in the viewport
    #   @param x [Integer]
    #   @param y [Integer]
    #   @return [self]
    # @!attribute [rw] z
    #   @return [Integer] z order of the Shape in the viewport
    # @!attribute [rw] ox
    #   @return [Integer] origin x of the Shape
    # @!attribute [rw] oy
    #   @return [Integer] origin y of the Shape
    # @!method set_origin(ox, oy)
    #   Change the origin of the Shape
    #   @param ox [Integer]
    #   @param oy [Integer]
    #   @return [self]
    # @!attribute [rw] angle
    #   @return [Numeric] angle of the shape
    # @!attribute [rw] zoom_x
    #   @return [Numeric] zoom_x of the shape
    # @!attribute [rw] zoom_y
    #   @return [Numeric] zoom_y of the shape
    # @!attribute [w] zoom
    #   @return [Numeric] zoom of the shape (x&y at the same time)
    # @!attribute [r] viewport
    #   @return [Viewport] viewport in which the Shape is shown
    # @!attribute [rw] visible
    #   @return [Boolean] if the shape is visible
    # @!attribute [rw] point_count
    #   @return [Numeric] number of point to build the shape (can be modified only with circle and convex)
    # @!method get_point(index)
    #   Retrieve the coordinate of a point
    #   @param index [Integer] index of the point in the point list
    #   @return [Array(Integer, Integer)]
    # @!method set_point(index, x, y)
    #   Update the coordinate of a point of a Convex shape (does nothing for rectangle Shape and Circle Shape)
    #   @param index [Integer] index of the point in the point list
    #   @param x [Numeric] x coordinate of the point
    #   @param y [Numeric] y coordinate of the point
    #   @return [self]
    # @!attribute [rw] color
    #   @return [Color] color of the shape (or multiplied to the bitmap)
    # @!attribute [rw] outline_color
    #   @return [Color] outline color of the shape
    # @!attribute [rw] outline_thickness
    #   @return [Numeric] size of the outline of the shape
    # @!attribute [r] __index__
    #   @return [Integer] internal index of the shape in the viewport when it was created
    # @!attribute [rw] radius
    #   @return [Numeric] radius of a circle shape (-1 if not a circle shape)
    # @!attribute [r] type
    #   @return [Symbol] type of the shape (:circle, :convex or :rectangle)
    # @!attribute [rw] width
    #   @return [Numeric] width of the shape (updatable only of :rectangle)
    # @!attribute [rw] height
    #   @return [Numeric] height of the shape (updatable only for :rectangle)
    # @!attribute [rw] shader
    #   @return [Shader, nil] shader used to draw the shape
    # @!attribute [rw] blendmode
    #   @return [BlendMode, nil] blend mode used to draw the shape
  end
  # Class that allow to draw tiles on a row
  class SpriteMap < Drawable
    # @!method self.new(viewport, tile_width, tile_count)
    #   Create a new SpriteMap
    #   @param viewport [Viewport] viewport used to draw the row
    #   @param tile_width [Integer] width of a tile
    #   @param tile_count [Integer] number of tile to draw in the row
    # @!method set_position(x, y)
    #   Set the position of the SpriteMap
    #   @param x [Numeric]
    #   @param y [Numeric]
    #   @return [self]
    # @!method set_origin(ox, oy)
    #   Set the origin of the textures of the SpriteMap
    #   @param ox [Numeric]
    #   @param oy [Numeric]
    #   @return [self]
    # @!method reset
    #   Clear the SpriteMap
    # @!method set(index, bitmap, rect)
    #   Set the tile to draw at a certain position in the row
    #   @param index [Integer] Index of the tile in the row
    #   @param bitmap [Bitmap] Bitmap to use in order to draw the tile
    #   @param rect [Rect] surface of the bitmap to draw in the tile
    # @!method set_rect(index, rect)
    #   @param index [Integer] Index of the tile in the row
    #   @param rect [Rect] surface of the bitmap to draw in the tile
    # @!method set_rect(index, x, y, width, height)
    #   @param index [Integer] Index of the tile in the row
    #   @param x [Integer] x coordinate of the surface in the bitmap
    #   @param y [Integer] y coordinate of the surface in the bitmap
    #   @param width [Integer] width of the surface in the bitmap
    #   @param height [Integer] height of the surface in the bitmap
    # @!attribute [r] viewport
    #   @return [Viewport] viewport used to draw the row
    # @!attribute [rw] x
    #   @return [Numeric] X position
    # @!attribute [rw] y
    #   @return [Numeric] Y position
    # @!attribute [rw] z
    #   @return [Integer] Z index
    # @!attribute [rw] ox
    #   @return [Numeric] origin X
    # @!attribute [rw] oy
    #   @return [Numeric] origin Y
    # @!attribute [rw] tile_scale
    #   @return [Numeric] scale of each tiles in the SpriteMap
    # @!attribute [r] __index__
    #   @return [Integer] Return the SpriteMap "index"
  end
  # Module that holds information about text fonts.
  #
  # You can define fonts loaded from a ttf file, you have to associate a default size, fill color and outline color to the font
  # 
  # You can define outline color and fill_color without defining a font but do not create a text with a font_id using the id of these color, it could raise an error, use load_color instead.
  module Fonts
    # @!method self.load_font(font_id, filename)
    #   Load a ttf
    #   @param font_id [Integer] the ID of the font you want to use to recall it in Text
    #   @param filename [String] the filename of the ttf file.
    #   @return [self]
    # @!method self.set_default_size(font_id, size)
    #   Define the default size of a font
    #   @param font_id [Integer] the ID of the font
    #   @param size [Integer] the default size
    #   @return [self]
    # @!method self.define_fill_color(font_id, color)
    #   Define the fill color of a font
    #   @param font_id [Integer] the ID of the font
    #   @param color [Color] the fill color
    #   @return [self]
    # @!method self.define_outline_color(font_id, color)
    #   Define the outline color of a font
    #   @param font_id [Integer] the ID of the font
    #   @param color [Color] the outline color
    #   @return [self]
    # @!method self.define_shadow_color(font_id, color)
    #   Define the shadow color of a font (WIP)
    #   @param font_id [Integer] the ID of the font
    #   @param color [Color] the shadow color
    #   @return [self]
    # @!method self.get_default_size(font_id)
    #   Retrieve the default size of a font
    #   @param font_id [Integer] the ID of the font
    #   @return [Integer]
    # @!method self.get_fill_color(font_id)
    #   Retrieve the fill color of a font
    #   @param font_id [Integer] the ID of the font
    #   @return [Color]
    # @!method self.get_outline_color(font_id)
    #   Retrieve the outline color of a font
    #   @param font_id [Integer] the ID of the font
    #   @return [Color]
    # @!method self.get_shadow_color(font_id)
    #   Retrieve the shadow color of a font
    #   @param font_id [Integer] the ID of the font
    #   @return [Color]
  end
  # BlendMode applicable to a ShaderedSprite
  class BlendMode
    # Add equation : Pixel = Src * SrcFactor + Dst * DstFactor
    Add = sf::BlendMode::Equation::Add
    # Substract equation : Pixel = Src * SrcFactor - Dst * DstFactor
    Subtract = sf::BlendMode::Equation::Subtract
    # Reverse substract equation : Pixel = Dst * DstFactor - Src * SrcFactor.
    ReverseSubtract = sf::BlendMode::Equation::ReverseSubtract
    # Zero factor : (0, 0, 0, 0)
    Zero = sf::BlendMode::Factor::Zero
    # One factor : (1, 1, 1, 1)
    One = sf::BlendMode::Factor::One
    # Src color factor : (src.r, src.g, src.b, src.a)
    SrcColor = sf::BlendMode::Factor::SrcColor
    # One minus src color factor : (1, 1, 1, 1) - (src.r, src.g, src.b, src.a)
    OneMinusSrcColor = sf::BlendMode::Factor::OneMinusSrcColor
    # Dest color factor : (dst.r, dst.g, dst.b, dst.a)
    DstColor = sf::BlendMode::Factor::DstColor
    # One minus dest color factor : (1, 1, 1, 1) - (dst.r, dst.g, dst.b, dst.a)
    OneMinusDstColor = sf::BlendMode::Factor::OneMinusDstColor
    # Src alpha factor : (src.a, src.a, src.a, src.a)
    SrcAlpha = sf::BlendMode::Factor::SrcAlpha
    # One minus src alpha factor : (1, 1, 1, 1) - (src.a, src.a, src.a, src.a)
    OneMinusSrcAlpha = sf::BlendMode::Factor::OneMinusSrcAlpha
    # Dest alpha factor : (dst.a, dst.a, dst.a, dst.a)
    DstAlpha = sf::BlendMode::Factor::DstAlpha
    # One minus dest alpha factor : (1, 1, 1, 1) - (dst.a, dst.a, dst.a, dst.a)
    OneMinusDstAlpha = sf::BlendMode::Factor::OneMinusDstAlpha
    # @!attribute [rw] color_src_factor
    #   @return [Integer] Return the source color factor
    # @!attribute [rw] color_dest_factor
    #   @return [Integer] Return the destination color factor
    # @!attribute [rw] alpha_src_factor
    #   @return [Integer] Return the source alpha factor
    # @!attribute [rw] alpha_dest_factor
    #   @return [Integer] Return the destination alpha factor
    # @!attribute [rw] color_equation
    #   @return [Integer] Return the color equation
    # @!attribute [rw] alpha_equation
    #   @return [Integer] Return the alpha equation
    # @!attribute [w] blend_type
    #   @return [Integer] Set the RMXP blend_type : 0 = normal, 1 = addition, 2 = substraction
  end
  # Shader loaded applicable to a ShaderedSprite
  class Shader < BlendMode
    # Define a Fragment shader
    Fragment = sf::Shader::Type::Fragment
    # Define a Vertex shader
    Vertex = sf::Shader::Type::Vertex
    # Define a Geometry shader
    Geometry = sf::Shader::Type::Geometry
    # @!method load(fragment_code)
    #   Load a fragment shader from memory
    #   @param fragment_code [String] shader code of the fragment shader
    # @!method load(code, type)
    #   Load a shader from memory
    #   @param code [String] the code of the shader
    #   @param type [Integer] the type of shader (Fragment, Vertex, Geometry)
    # @!method load(vertex_code, fragment_code)
    #   Load a vertex and fragment shader from memory
    #   @param vertex_code [String]
    #   @param fragment_code [String]
    # @!method load(vertex_code, geometry_code, fragment_code)
    #   Load a full shader from memory
    #   @param vertex_code [String]
    #   @param geometry_code [String]
    #   @param fragment_code [String]
    # @!method self.new(fragment_code)
    #   Load a fragment shader from memory
    #   @param fragment_code [String] shader code of the fragment shader
    # @!method self.new(code, type)
    #   Load a shader from memory
    #   @param code [String] the code of the shader
    #   @param type [Integer] the type of shader (Fragment, Vertex, Geometry)
    # @!method self.new(vertex_code, fragment_code)
    #   Load a vertex and fragment shader from memory
    #   @param vertex_code [String]
    #   @param fragment_code [String]
    # @!method self.new(vertex_code, geometry_code, fragment_code)
    #   Load a full shader from memory
    #   @param vertex_code [String]
    #   @param geometry_code [String]
    #   @param fragment_code [String]
    # @!method set_float_uniform(name, uniform)
    #   Set a Float type uniform
    #   @param name [String] name of the uniform
    #   @param uniform [Float, Array<Float>, LiteRGSS::Color, LiteRGSS::Tone] Array must have 2, 3 or 4 Floats
    # @!method set_int_uniform(name, uniform)
    #   Set a Integer type uniform
    #   @param name [String] name of the uniform
    #   @param uniform [Integer, Array<Integer>] Array must have 2, 3 or 4 Integers
    # @!method set_bool_uniform(name, uniform)
    #   Set a Boolean type uniform
    #   @param name [String] name of the uniform
    #   @param uniform [Boolean, Array<Boolean>]  Array must have 2, 3 or 4 Booleans
    # @!method set_texture_uniform(name, uniform)
    #   Set a Texture type uniform
    #   @param name [String] name of the uniform
    #   @param uniform [LiteRGSS::Bitmap, nil] nil means sf::Shader::CurrentTexture
    # @!method set_matrix_uniform(name, uniform)
    #   Set a Matrix type uniform (3x3 or 4x4)
    #   @param name [String] name of the uniform
    #   @param uniform [Array<Float>] Array must be 9 for 3x3 matrix or 16 for 4x4 matrix
    # @!method set_float_array_uniform(name, uniform)
    #   Set a Float Array type uniform
    #   @param name [String] name of the uniform
    #   @param uniform [Array<Float>]
  end
  # Class that describe a Shadered Sprite
  class ShaderedSprite < Sprite
    # @!attribute [rw] shader
    #   @return [Shader, BlendMode] Set the sprite shader
    # @!attribute [rw] blendmode
    #   @return [Shader, BlendMode] Set the sprite BlendMode
  end
  # Class that describe a Window holding the OpenGL context & all drawable
  class DisplayWindow
    # Maximum size of the texture for the device the OpenGL context are currently running over
    MAX_TEXTURE_SIZE = 1024
    # @!method self.new(title, width, height, scale, bpp = 32, frame_rate = 60, vsync = false, fullscreen = false, mouse_visible = false)
    #   Create a new DisplayWindow
    #   @param title [String] title of the window
    #   @param width [Integer] width of the window content
    #   @param height [Integer] height of the window content
    #   @param scale [Float] scale of the window content (if width = 320 & scale = 2, window final width is 640 + frame)
    #   @param bpp [Integer] number of bit per pixels
    #   @param frame_rate [Integer] locked framerate of the window, 0 = unlimited fps
    #   @param vsync [Boolean] if vsync is on or off
    #   @param fullscreen [Boolean] if window should be in fullscreen mode
    #   @param mouse_visible [Boolean] if the mouse should be visible inside the window
    # @!method dispose
    #   Dispose the window and forcefully close it
    # @!method update
    #   Update window content & events. This method might wait for vsync before updating events
    #   @return [self]
    # @!method sort_z
    #   Update window internal order according to z of each entities
    #   @return [self]
    # @!method snap_to_bitmap
    #   Take a snapshot of the window content
    #   @return [Bitmap]
    # @!attribute [r] width
    #   @return [Integer] get the width of the window
    # @!attribute [r] height
    #   @return [Integer] get the height of the window
    # @!method update_no_input
    #   Update the window content. This method might wait for vsync before returning
    #   @return [self]
    # @!method update_only_input
    #   Update the window event without drawing anything.
    #   @return [self]
    # @!attribute [rw] shader
    #   @return [Shader] Set the global shader applied to the final content of the window (shader is applied with total pixel size and not native pixel size)
    # @!attribute [w] icon
    #   @return [Image] Set the icon of the window
    # @!method resize_screen(width, height)
    #   Change the window screen size but keep every other parameter in the same settings
    #   @param width [Integer]
    #   @param height [Integer]
    #   @return [self]
    # @!attribute [rw] settings
    #   @return [Array(title, width, height, scale, bpp, fps, vsync, fullscreen, visible_mouse)]
    # @!attribute [rw] x
    #   @return [Integer] X coordinate of the window on the desktop
    # @!attribute [rw] y
    #   @return [Integer] Y coordinate of the window on the desktop
    # @!attribute [r] openGL_version
    #   @return [Array<Integer>] Major & Minor version number of the currently running OpenGL version
    # @!method on_closed=(proc)
    #   Define the event called when the on close event is detected
    #   @example Prevent the user from closing the window if $no_close is true
    #     win.on_close = proc do
    #       next false if $no_close
    #
    #       next true
    #     end
    # @!method on_resized=(proc)
    #   Define the event called when the resize event is detected
    #   @example Detect that the window was resize
    #     win.on_resized = proc do |width, height|
    #       puts "Resized to : (#{width}, #{height})"
    #     end
    # @!method on_lost_focus=(proc)
    #   Define the event called when the window lost focus
    #   @example Detect that the window lost focus
    #     win.on_lost_focus = proc do
    #       puts "Lost focus"
    #     end
    # @!method on_gained_focus=(proc)
    #   Define the event called when the window gains focus
    #   @example Detect that the window gained focus
    #     win.on_gained_focus = proc do
    #       puts "Focus gained"
    #     end
    # @!method on_text_entered=(proc)
    #   Define the event called when a text entry is detected on the window (usally a character representing the UTF-8 pressed key)
    #   @example Detect the text entered
    #     win.on_text_entered = proc do |text|
    #       puts "User entered : #{text}"
    #     end
    # @!method on_key_pressed=(proc)
    #   Define the event called when a key is pressed
    #   @example Detect the key press
    #     win.on_key_pressed = proc do |key, alt, control, shift, system|
    #       puts "User pressed #{key} with following state: a:#{alt}, c:#{control}, s:#{shift}, sys:#{system}"
    #     end
    # @!method on_key_released=(proc)
    #   Define the event called when a key is released
    #   @example Detect the key release
    #     win.on_key_released = proc do |key|
    #       puts "User released #{key}"
    #     end
    # @!method on_mouse_wheel_scrolled=(proc)
    #   Define the event called when the mouse wheel is scrolled
    #   @example Detect a mouse wheel event
    #     win.on_mouse_wheel_scrolled = proc do |wheel, delta|
    #       puts "Mouse wheel ##{wheel} scrolled #{delta}"
    #     end
    # @!method on_mouse_button_pressed=(proc)
    #   Define the event called when a mouse key is pressed
    #   @example Detect a mouse press event
    #     win.on_mouse_button_pressed = proc do |button|
    #       puts "Mouse button pressed: #{button}"
    #     end
    # @!method on_mouse_button_released=(proc)
    #   Define the event called when a mouse key is released
    #   @example Detect a mouse key released event
    #     win.on_mouse_button_released = proc do |button|
    #       puts "Mouse button released: #{button}"
    #     end
    # @!method on_mouse_moved=(proc)
    #   Define the event called when the mouse moves
    #   @example Detect a mouse moved event
    #     win.on_mouse_moved = proc|x, y|
    #       puts "Mouse moved to: (#{x}, #{y})"
    #     end
    # @!method on_mouse_entered=(proc)
    #   Define the event called when the mouse enters the window
    #   @example Detect a mouse enter event
    #     win.on_mouse_entered = proc { puts "Mouse entered the screen" }
    # @!method on_mouse_left=(proc)
    #   Define the event called when the mouse leaves the window
    #   @example Detect a move left event
    #     win.on_mouse_left = proc { puts "Mouse left the screen" }
    # @!method on_joystick_button_pressed=(proc)
    #   Define the event called when a button is pressed on a joystick
    #   @example Detect the button press of a joystick
    #     win.on_joystick_button_pressed = proc do |joy_id, button|
    #       puts "Joystick button ##{button} on stick ##{joy_id} was pressed"
    #     end
    # @!method on_joystick_button_released=(proc)
    #   Define the event called when a button is released on a joystick
    #   @example Detect a button release of a joystick
    #     win.on_joystick_button_released = proc do |joy_id, button|
    #       puts "Joystick button ##{button} on stick ##{joy_id} was released"
    #     end
    # @!method on_joystick_moved=(proc)
    #   Define the event called when a joystick axis is moved
    #   @example Detect a joystick axis movement
    #     win.on_joystick_moved = proc do |joy_id, axis, position|
    #       puts "Axis #{axis} of joystick ##{joy_id} moved to #{position}"
    #     end
    # @!method on_joystick_connected=(proc)
    #   Define the event called when a joystick gets plugged in
    #   @example Detect a joystick connection
    #     win.on_joystick_connected = proc do |joy_id|
    #       puts "Joystick #{joy_id} connected!"
    #     end
    # @!method on_joystick_disconnected=(proc)
    #   Define the event called when a joystick gets unplugged
    #   @example Detect a joystick disconnection
    #     win.on_joystick_disconnected = proc do |joy_id|
    #       puts "Joystick #{joy_id} disconnected!"
    #     end
    # @!method on_touch_began=(proc)
    #   Define the event called when a touch event has begun
    #   @example Detect a touch event that begins
    #     win.on_touch_began = proc do |finger_id, x, y|
    #       puts "Touch ##{finger_id} started on: (#{x}, #{y})"
    #     end
    # @!method on_touch_moved=(proc)
    #   Define the event called when the touch moved
    #   @example Detect a touch moved example
    #     win.on_touch_moved = proc do |finger_id, x, y|
    #       puts "Touch ##{finger_id} moved to: (#{x}, #{y})"
    #     end
    # @!method on_touch_ended=(proc)
    #   Define the event called when the touche ended
    #   @example Detect a touch end event
    #     win.on_touch_ended = proc do |finger_id, x, y|
    #       puts "Touch ##{finger_id} ended on: (#{x}, #{y})"
    #     end
    # @!method on_sensor_changed=(proc)
    #   Define the event called when a sensor event was triggered
    #   @example Detect a sensor change
    #     win.on_sensor_changed = proc do |sensor_type, x, y, z|
    #       puts "Sensor #{sensor_type} changed to: (#{x}, #{y}, #{z})"
    #     end
    # @!method self.list_resolutions
    #   List all the resolution available on the current device
    #   @return [Array] [[width1, height1], [width2, height2], ...]
    # @!method self.desktop_width
    #   Get the desktop width
    #   @return [Integer]
    # @!method self.desktop_height
    #   Get the desktop height
    #   @return [Integer]
  end
end
# Module of things made by Nuri Yuri
module Yuki
  # @!method self.get_clipboard
  #   Get the clipboard contents
  #   @return [String, nil] nil if no clipboard or incompatible clipboard
  # @!method self.set_clipboard(text)
  #   Set the clipboard text contents
  #   @param text [String]
end
module Yuki
  # Class that helps to read Gif
  class GifReader
    # @!attribute [rw] width
    #   @return [Integer] Return the width of the Gif image
    # @!attribute [rw] height
    #   @return [Integer] Return the height of the Gif image
    # @!attribute [rw] frame
    #   @return [Integer] Return the frame index of the Gif image
    # @!attribute [r] frame_count
    #   @return [Integer] Return the number of frame in the Gif image
    # @!method self.new(filenameordata, from_memory = false)
    #   Create a new GifReader
    #   @param filenameordata [String]
    #   @param from_memory [Boolean]
    # @!method update(bitmap)
    #   Update the gif animation
    #   @param bitmap [LiteRGSS::Bitmap] texture that receive the update
    #   @return [self]
    # @!method draw(bitmap)
    #   Draw the current frame in a bitmap
    #   @param bitmap [LiteRGSS::Bitmap] texture that receive the frame
    #   @return [self]
    # @!method self.delta_counter=(value)
    #   Set the delta counter used to count frames
    #   @param value [Numeric] the number of miliseconds per frame
    # Describe an error that happend during gif processing
    class Error < StandardError
    end
  end
end
# Class that store a 3D array of value coded with 16bits (signed)
class Table
  # @!method self.new(xsize, ysize = 1, zsize = 1)
  #   Create a new table without pre-initialization of the contents
  #   @param xsize [Integer] number of row
  #   @param ysize [Integer] number of cols
  #   @param zsize [Integer] number of 2D table
  #   @note Never call initialize from the Ruby code other than using Table.new. It'll create memory if you call initialize from Ruby, use #resize instead.
  # @!method [](x, y = 0, z = 0)
  #   Access to a value of the table
  #   @param x [Integer] index of the row
  #   @param y [Integer] index of the col
  #   @param z [Integer] index of the 2D table
  #   @return [Integer, nil] nil if x, y or z are outside of the table.
  # @!method []=(x, value)
  #   Change a value in the table
  #   @param x [Integer] row to affect to the new value
  #   @param value [Integer] new value
  # @!method []=(x, y, value)
  #   Change a value in the table
  #   @param x [Integer] row index of the cell to affect to the new value
  #   @param y [Integer] col index of the cell to affect to the new value
  #   @param value [Integer] new value
  # @!method []=(x, y, z, value)
  #   Change a value in the table
  #   @param x [Integer] row index of the cell to affect to the new value
  #   @param y [Integer] col index of the cell to affect to the new value
  #   @param z [Integer] index of the table containing the cell to affect to the new value
  #   @param value [Integer] new value
  # @!attribute [r] xsize
  # @return [Integer] number of row in the table
  # @!attribute [r] ysize
  # @return [Integer] number of cols in the table
  # @!attribute [r] zsize
  # @return [Integer] number of 2D table in the table
  # @!attribute [r] dim
  # @return [Integer] Dimension of the table (1D, 2D, 3D)
  # @!method resize(xsize, ysize = 1, zsize = 1)
  #   Resize the table
  #   @param xsize [Integer] number of row
  #   @param ysize [Integer] number of cols
  #   @param zsize [Integer] number of 2D table
  #   @note Some value may be undeterminated if the new size is bigger than the old size
  # @!method fill(value)
  #   Fill the whole table with a specific value
  #   @param value [Integer] the value to affect to every cell of the table
  # @!method copy(table, dest_offset_x, dest_offset_y)
  #   Copy another table to this table
  #   @param table [Table] the other table
  #   @param dest_offset_x [Integer] index of the row that will receive the first row of the other table
  #   @param dest_offset_y [Integer] index of the col that will receive the first colum of the other table
  #   @return [Boolean] if the operation was done
  #   @note If any parameter is invalid (eg. dest_offset_coord < 0) the function does nothing.
  # @!method copy_modulo(table, source_origin_x, source_origin_y, dest_offset_x, dest_offset_y, width, height)
  #   Copy another table to a specified surface of the current table using a circular copy (dest_coord = offset + source_coord % source_size)
  #   @param table [Table] the other table
  #   @param source_origin_x [Integer] index of the first row to copy in the current table
  #   @param source_origin_y [Integer] index of the first col to copy in the current table
  #   @param dest_offset_x [Integer] index of the row that will receive the first row of the other table
  #   @param dest_offset_y [Integer] index of the col that will receive the first colum of the other table
  #   @param width [Integer] width of the destination surface that receive the other table values
  #   @param height [Integer] height of the destination surface that receive the other table values
end
# Class that store a 3D array of value coded with 32bits (signed)
class Table32
  # @!method self.new(xsize, ysize = 1, zsize = 1)
  #   Create a new table without pre-initialization of the contents
  #   @param xsize [Integer] number of row
  #   @param ysize [Integer] number of cols
  #   @param zsize [Integer] number of 2D table
  #   @note Never call initialize from the Ruby code other than using Table.new. It'll create memory if you call initialize from Ruby, use #resize instead.
  # @!method [](x, y = 0, z = 0)
  #   Access to a value of the table
  #   @param x [Integer] index of the row
  #   @param y [Integer] index of the col
  #   @param z [Integer] index of the 2D table
  #   @return [Integer, nil] nil if x, y or z are outside of the table.
  # @!method []=(x, value)
  #   Change a value in the table
  #   @param x [Integer] row to affect to the new value
  #   @param value [Integer] new value
  # @!method []=(x, y, value)
  #   Change a value in the table
  #   @param x [Integer] row index of the cell to affect to the new value
  #   @param y [Integer] col index of the cell to affect to the new value
  #   @param value [Integer] new value
  # @!method []=(x, y, z, value)
  #   Change a value in the table
  #   @param x [Integer] row index of the cell to affect to the new value
  #   @param y [Integer] col index of the cell to affect to the new value
  #   @param z [Integer] index of the table containing the cell to affect to the new value
  #   @param value [Integer] new value
  # @!attribute [r] xsize
  # @return [Integer] number of row in the table
  # @!attribute [r] ysize
  # @return [Integer] number of cols in the table
  # @!attribute [r] zsize
  # @return [Integer] number of 2D table in the table
  # @!attribute [r] dim
  # @return [Integer] Dimension of the table (1D, 2D, 3D)
  # @!method resize(xsize, ysize = 1, zsize = 1)
  #   Resize the table
  #   @param xsize [Integer] number of row
  #   @param ysize [Integer] number of cols
  #   @param zsize [Integer] number of 2D table
  #   @note Some value may be undeterminated if the new size is bigger than the old size
  # @!method fill(value)
  #   Fill the whole table with a specific value
  #   @param value [Integer] the value to affect to every cell of the table
end
# Module containing some utilities comming from SFML
module Sf
  # Sensor utility of SFML
  module Sensor
    # Accelerometer sensor type
    ACCELEROMETER = sf::Sensor::Type::Accelerometer
    # Gyroscope sensor type
    GYROSCOPE = sf::Sensor::Type::Gyroscope
    # Magnetometer sensor type
    MAGNETOMETER = sf::Sensor::Type::Magnetometer
    # Gravity sensor type
    GRAVITY = sf::Sensor::Type::Gravity
    # UserAcceleration sensor type
    USER_ACCELERATION = sf::Sensor::Type::UserAcceleration
    # Orientation sensor type
    ORIENTATION = sf::Sensor::Type::Orientation
    # @!method self.available?(type)
    #   Tell if a sensor is available
    #   @param type [Integer] type of sensor
    #   @return [Boolean]
    # @!method self.set_enabled(type, enabled)
    #   Set the enabled state of a sensor
    #   @param type [Integer] sensor type
    #   @param enabled [Boolean] enable state of the sensor
    #   @return [self]
    # @!method self.value(type)
    #   Get the current value of the sensor
    #   @param type [Integer] sensor type
    #   @return [Array<Float>] x, y, z value of the sensor
  end
  # Mouse utility of SFML
  module Mouse
    # Left button code
    LEFT = Left = sf::Mouse::Button::Left
    # Right button code
    RIGHT = Right = sf::Mouse::Button::Right
    # Middle button code
    Middle = sf::Mouse::Button::Middle
    # XButton1 button code
    XButton1 = sf::Mouse::Button::XButton1
    # XButton2 button code
    XButton2 = sf::Mouse::Button::XButton2
    # Vertical wheel id
    VerticalWheel = sf::Mouse::Wheel::VerticalWheel
    # Horizontal wheel id
    HorizontalWheel = sf::Mouse::Wheel::HorizontalWheel
    # @!method self.press?(button)
    #   Tell if a button of the mouse is pressed
    #   @param button [Integer] code of the button
    #   @return [Boolean]
    # @!method self.position
    #   Get the current position of the mouse in desktop coordinate
    #   @return [Array<Integer>]
    # @!method self.set_position(x, y)
    #   Set the position of the mouse in desktop coordinate
    #   @return [self]
  end
  # Keyboard utility of SFML
  module Keyboard
    # A key
    A = sf::Keyboard::A
    # B key
    B = sf::Keyboard::B
    # C key
    C = sf::Keyboard::C
    # D key
    D = sf::Keyboard::D
    # E key
    E = sf::Keyboard::E
    # F key
    F = sf::Keyboard::F
    # G key
    G = sf::Keyboard::G
    # H key
    H = sf::Keyboard::H
    # I key
    I = sf::Keyboard::I
    # J key
    J = sf::Keyboard::J
    # K key
    K = sf::Keyboard::K
    # L key
    L = sf::Keyboard::L
    # M key
    M = sf::Keyboard::M
    # N key
    N = sf::Keyboard::N
    # O key
    O = sf::Keyboard::O
    # P key
    P = sf::Keyboard::P
    # Q key
    Q = sf::Keyboard::Q
    # R key
    R = sf::Keyboard::R
    # S key
    S = sf::Keyboard::S
    # T key
    T = sf::Keyboard::T
    # U key
    U = sf::Keyboard::U
    # V key
    V = sf::Keyboard::V
    # W key
    W = sf::Keyboard::W
    # X key
    X = sf::Keyboard::X
    # Y key
    Y = sf::Keyboard::Y
    # Z key
    Z = sf::Keyboard::Z
    # Num0 key
    Num0 = sf::Keyboard::Num0
    # Num1 key
    Num1 = sf::Keyboard::Num1
    # Num2 key
    Num2 = sf::Keyboard::Num2
    # Num3 key
    Num3 = sf::Keyboard::Num3
    # Num4 key
    Num4 = sf::Keyboard::Num4
    # Num5 key
    Num5 = sf::Keyboard::Num5
    # Num6 key
    Num6 = sf::Keyboard::Num6
    # Num7 key
    Num7 = sf::Keyboard::Num7
    # Num8 key
    Num8 = sf::Keyboard::Num8
    # Num9 key
    Num9 = sf::Keyboard::Num9
    # Escape key
    Escape = sf::Keyboard::Escape
    # LControl key
    LControl = sf::Keyboard::LControl
    # LShift key
    LShift = sf::Keyboard::LShift
    # LAlt key
    LAlt = sf::Keyboard::LAlt
    # LSystem key
    LSystem = sf::Keyboard::LSystem
    # RControl key
    RControl = sf::Keyboard::RControl
    # RShift key
    RShift = sf::Keyboard::RShift
    # RAlt key
    RAlt = sf::Keyboard::RAlt
    # RSystem key
    RSystem = sf::Keyboard::RSystem
    # Menu key
    Menu = sf::Keyboard::Menu
    # LBracket key
    LBracket = sf::Keyboard::LBracket
    # RBracket key
    RBracket = sf::Keyboard::RBracket
    # Semicolon key
    Semicolon = sf::Keyboard::Semicolon
    # Comma key
    Comma = sf::Keyboard::Comma
    # Period key
    Period = sf::Keyboard::Period
    # Quote key
    Quote = sf::Keyboard::Quote
    # Slash key
    Slash = sf::Keyboard::Slash
    # Backslash key
    Backslash = sf::Keyboard::Backslash
    # Tilde key
    Tilde = sf::Keyboard::Tilde
    # Equal key
    Equal = sf::Keyboard::Equal
    # Hyphen key
    Hyphen = sf::Keyboard::Hyphen
    # Space key
    Space = sf::Keyboard::Space
    # Enter key
    Enter = sf::Keyboard::Enter
    # Backspace key
    Backspace = sf::Keyboard::Backspace
    # Tab key
    Tab = sf::Keyboard::Tab
    # PageUp key
    PageUp = sf::Keyboard::PageUp
    # PageDown key
    PageDown = sf::Keyboard::PageDown
    # End key
    End = sf::Keyboard::End
    # Home key
    Home = sf::Keyboard::Home
    # Insert key
    Insert = sf::Keyboard::Insert
    # Delete key
    Delete = sf::Keyboard::Delete
    # Add key
    Add = sf::Keyboard::Add
    # Subtract key
    Subtract = sf::Keyboard::Subtract
    # Multiply key
    Multiply = sf::Keyboard::Multiply
    # Divide key
    Divide = sf::Keyboard::Divide
    # Left key
    Left = sf::Keyboard::Left
    # Right key
    Right = sf::Keyboard::Right
    # Up key
    Up = sf::Keyboard::Up
    # Down key
    Down = sf::Keyboard::Down
    # Numpad0 key
    Numpad0 = sf::Keyboard::Numpad0
    # Numpad1 key
    Numpad1 = sf::Keyboard::Numpad1
    # Numpad2 key
    Numpad2 = sf::Keyboard::Numpad2
    # Numpad3 key
    Numpad3 = sf::Keyboard::Numpad3
    # Numpad4 key
    Numpad4 = sf::Keyboard::Numpad4
    # Numpad5 key
    Numpad5 = sf::Keyboard::Numpad5
    # Numpad6 key
    Numpad6 = sf::Keyboard::Numpad6
    # Numpad7 key
    Numpad7 = sf::Keyboard::Numpad7
    # Numpad8 key
    Numpad8 = sf::Keyboard::Numpad8
    # Numpad9 key
    Numpad9 = sf::Keyboard::Numpad9
    # F1 key
    F1 = sf::Keyboard::F1
    # F2 key
    F2 = sf::Keyboard::F2
    # F3 key
    F3 = sf::Keyboard::F3
    # F4 key
    F4 = sf::Keyboard::F4
    # F5 key
    F5 = sf::Keyboard::F5
    # F6 key
    F6 = sf::Keyboard::F6
    # F7 key
    F7 = sf::Keyboard::F7
    # F8 key
    F8 = sf::Keyboard::F8
    # F9 key
    F9 = sf::Keyboard::F9
    # F10 key
    F10 = sf::Keyboard::F10
    # F11 key
    F11 = sf::Keyboard::F11
    # F12 key
    F12 = sf::Keyboard::F12
    # F13 key
    F13 = sf::Keyboard::F13
    # F14 key
    F14 = sf::Keyboard::F14
    # F15 key
    F15 = sf::Keyboard::F15
    # Pause key
    Pause = sf::Keyboard::Pause
    # @!method self.press?(key)
    #   Tell if the key is pressed
    #   @param key [Integer]
    #   @return [Boolean]
  end
  # Joystick utility of SFML
  module Joystick
    # Number of joystick SFML is able to handle at once
    COUNT = 8
    # Number of key on a joystick SFML is able to handle at once
    BUTTON_COUNT = 32
    # Number of axis SFML is able to handle on a joystick at once
    AXIS_COUNT = 8
    # X axis
    X = sf::Joystick::Axis::X
    # Y axis
    Y = sf::Joystick::Axis::Y
    # Z axis
    Z = sf::Joystick::Axis::Z
    # R axis
    R = sf::Joystick::Axis::R
    # U axis
    U = sf::Joystick::Axis::U
    # V axis
    V = sf::Joystick::Axis::V
    # PovX axis
    POV_X = sf::Joystick::Axis::PovX
    # PovY axis
    POV_Y = sf::Joystick::Axis::PovY
    # @!method self.connected?(id)
    #   Tell if the joystick id is currently connected
    #   @param id [Integer]
    #   @return [Boolean]
    # @!method self.button_count(id)
    #   Give the number of button on the joystick id
    #   @param id [Integer]
    #   @return [Integer]
    # @!method self.axis_available?(id, axis)
    #   Tell if the given axis is available on joystick id
    #   @param id [Integer]
    #   @param axis [Integer]
    #   @return [Boolean]
    # @!method self.press?(id, button)
    #   Tell if the button is pressed on joystick id
    #   @param id [Integer]
    #   @param button [Integer]
    # @!method self.axis_position(id, axis)
    #   Gives the axis position of joystick id
    #   @param id [Integer]
    #   @param axis [Integer]
    #   @return [Float] position between -100.0 & 100.0
    # @!method self.update
    #   Update the state of joystick
    #   @return [self]
    # @!method self.identification(id)
    #   Gives the joystick identification information
    #   @param id [Integer]
    #   @return [Array] "name", vendor_id (int), product_id (int)
  end
end
