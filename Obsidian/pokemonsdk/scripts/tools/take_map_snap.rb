# Convert PSDK Data to JSON
#
# To use it, write `ScriptLoader.load_tool('take_map_snap')`
# in a script or the PSDK Console. (It helps to load it)
#
# Once the script loaded you can use the function
# `take_map_snap('screenshot.png')`
#
# You can use `Debugger.warp(map_id, x, y)`
# To go to the desired map
def take_map_snap(filename, tile_size = 16)
  opt = $game_player.transparent
  $game_player.transparent = true
  Yuki::FollowMe.smart_disable
  ori_x = $game_player.x
  ori_y = $game_player.y
  off_x = Yuki::MapLinker.get_OffsetX
  off_y = Yuki::MapLinker.get_OffsetY
  width = (($game_map.width - 2 * off_x) / 20.0).ceil
  height = (($game_map.height - 2 * off_y) / 15.0).ceil
  images = Array.new(width) do |x|
    Array.new(height) do |y|
      Graphics.frame_count = 1
      $game_player.center(x * 20 + 10 + off_x, y * 15 + 7 + off_y)
      $scene.spriteset.update
      bmp = $scene.snap_to_bitmap
      png = bmp.to_png
      bmp.dispose
      next png
    end
  end
  rc = $scene.spriteset.map_viewport.rect
  img = Image.new(width * rc.width, height * rc.height)
  images.each_with_index do |arr, x|
    arr.each_with_index do |png, y|
      image = Image.new(png, true)
      img.blt!(x * rc.width, y * rc.height, image, image.rect)
      image.dispose
    end
  end
  img2 = Image.new(($game_map.width - 2 * off_x) * tile_size - tile_size / 2, ($game_map.height - 2 * off_y) * tile_size)
  img2.blt!(0, 0, img, img2.rect)
  img2.to_png_file(filename)
  img.dispose
  img2.dispose
  $game_player.moveto(ori_x, ori_y)
  $game_player.transparent = opt
  Yuki::FollowMe.smart_enable
end
