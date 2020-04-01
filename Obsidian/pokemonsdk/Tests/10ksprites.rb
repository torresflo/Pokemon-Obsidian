r = Random.new
vp = Viewport.create(:main, 1000)
sp = Array.new(10_000) do
  Sprite.new(vp).set_bitmap("4G tileset_glace", :tileset)
end
Graphics.transition
loop do
  Graphics.update
  sp.each { |sp| sp.set_position(r.rand(320), r.rand(240)).src_rect.set(r.rand(8) * 32, r.rand(20) * 32, 32, 32) }
end