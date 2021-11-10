# This script allow to convert a save to a picture (Image object)
#
# To get access to this script write :
#   ScriptLoader.load_tool('SaveToPicture')
#
# To execute this script write :
#   SaveToPicture.run
#
# To save specific data, write:
#   SaveToPicture.run(data: bin_string_to_save)
# To restore a save from a picture write :
#   SaveToPicture.run(restore: 'filename.png', to: 'Saves/Pokemon_Party-1')
module SaveToPicture
  # Regular width of the image
  IMAGE_MAX_WITH = 479
  class << self
    # Run the SaveToPicture utility
    # @param restore [String] name of the image to restore to a save
    # @param to [String] name of the file holding the result save
    # @param data [String] data to save
    # @return [Image]
    def run(restore: nil, to: nil, data: nil)
      return restore_save(restore, to) if restore && to

      return make_picture(data || GamePlay::Save.save(nil, true))
    end

    private

    # Restore a save from a PNG file
    # @param restore [String] name of the image to restore to a save
    # @param to [String] name of the file holding the result save
    def restore_save(restore, to)
      image = Image.new(restore)
      color = image.get_pixel(image.width / 2, 0)
      stop_condition = [color.red, color.green, color.blue, 0].pack('C4').unpack1('I<')
      x = 0
      y = 1
      data = ''.force_encoding(Encoding::ASCII_8BIT)
      while data.bytesize < stop_condition
        color = image.get_pixel(x, y)
        data << color.red
        data << color.green
        data << color.blue
        x += 1
        next if x < image.width

        x = 0
        y += 1
        break if y >= image.height
      end
      File.binwrite(to, data[0, stop_condition])
      return image
    end

    # Transform a save into a Image
    # @param data [String] data to save
    def make_picture(data)
      width = Math.sqrt(data.bytesize / 3.0).ceil
      width = IMAGE_MAX_WITH if width >= (IMAGE_MAX_WITH / 2)
      height = (data.bytesize / 3.0 / width).ceil
      color = Color.new(0, 0, 0, 255)
      image = Image.new(width, height + 2)
      image.fill_rect(0, 0, width, 1, color)
      image.fill_rect(0, height + 1, width, 1, color)
      color.set(*[data.bytesize].pack('I<').unpack('C3'), 255)
      image.set_pixel(width / 2, 0, color)
      image.set_pixel(width - 1, 0, color)
      image.set_pixel(0, 0, color)
      x = 0
      y = 1
      data.each_byte.each_slice(3) do |(r, g, b)|
        color.set(r, g, b, 255)
        image.set_pixel(x, y, color)
        x += 1
        if x >= width
          x = 0
          y += 1
        end
      end
      return image
    end
  end
end
