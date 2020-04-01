img = Image.new('Graphics/Battlers/dp_source.png')
img.create_mask(Color.new(255, 0, 255), 0)
dst = Image.new(80, 80)
(img.height / 81).times do |y|
  (img.width / 81).times do |x|
    dst.blt!(0, 0, img, Rect.new(x * 81, y * 81 + 1, 80, 80))
    dst.to_png_file(format('Graphics/Battlers/dp_%02d.png', x + y * 10 + 1))
  end
end