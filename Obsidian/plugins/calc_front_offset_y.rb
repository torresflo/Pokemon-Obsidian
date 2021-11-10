def find_height(img)
  first_y = img.height.times.find { |y|
    img.width.times.any? { |x| img.get_pixel_alpha(x, y) != 0 }
  }
  return img.height - first_y.to_i
end
GameData::Pokemon.load
Dir['graphics/pokedex/pokefront/*.png'].each do |fn|
  if match = fn.match(/graphics\/pokedex\/pokefront\/([0-9]{3})_?([0-9]{2})?\.png/)
    id = match.captures[0].to_i
    form = match.captures[1].to_i
    img = Image.new(fn)
    GameData::Pokemon[id, form].front_offset_y = (96 - find_height(img)) / 2
    img.dispose
  end
end
save_data(GameData::Pokemon.all, 'Data/PSDK/PokemonData.rxdata')