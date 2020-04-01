img = Image.new('Graphics/Battlers/dp_back_source.png')
dst = Image.new(80, 160)
(2).times do |y|
  (img.width / 81).times do |x|
    dst.blt!(0, 0, img, Rect.new(x * 81, y * 162 + 1, 80, 80))
    dst.blt!(0, 80, img, Rect.new(x * 81, y * 162 + 81 + 1, 80, 80))
    dst.to_png_file(format('Graphics/Battlers/dp_back_%02d.png', x + y * 2 + 1))
  end
end