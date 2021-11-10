@image = Image.new(40, 30)
pix_to_draw = 40 * 30
number_of_second_color = (pix_to_draw / 255.0).ceil
color_delta = (255.0 / number_of_second_color).ceil
color = Color.new(0, 0, 0, 255)

@x = 0
@y = 0
@dir = 2

# Update the x/y position
def update_xy
  case @dir
  when 2
    if test_xy(0, 1)
      @dir = 6
      @x += 1
    else
      @y += 1
    end
  when 6
    if test_xy(1, 0)
      @dir = 8
      @y -= 1
    else
      @x += 1
    end
  when 8
    if test_xy(0, -1)
      @dir = 4
      @x -= 1
    else
      @y -= 1
    end
  else
    if test_xy(-1, 0)
      @dir = 2
      @y += 1
    else
      @x -= 1
    end
  end
end

# Test if we should change our x/y direction
# @param dx [Integer] what to add in x
# @param dy [Integer] what to add in y
# @return [Boolean] if the direction should be changed
def test_xy(dx, dy)
  x = @x + dx
  return true if x < 0 || x >= @image.width
  y = @y + dy
  return true if y < 0 || y >= @image.height
  return @image.get_pixel_alpha(x, y) == 255
end


pix_to_draw.times do |i|
  color.red = i / number_of_second_color
  color.green = (i % number_of_second_color) * color_delta
  @image.set_pixel(@x, @y, color)
  update_xy
end

@image.to_png_file('test.png')