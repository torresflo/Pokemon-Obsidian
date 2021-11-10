class NewRendererTest < GamePlay::BaseCleanUpdate
  attr_reader :tilemap
  def initialize
    super()
    @ox = 0
    @oy = 0
    @max = 0
    @min = Float::INFINITY
    @moy = 0
    @count = 0
  end

  def create_graphics
    create_viewport
	if PSDK_CONFIG.debug?
		Graphics.resize_screen(320 + 32, 240 + 32)
		@viewport.rect.set(0, 0, Graphics.width, Graphics.height)
		@viewport.ox = -16
		@viewport.oy = -16
	end
    @tilemap = Yuki::Tilemap16px.new(@viewport)
    data1 = load_data('Data/Map005.rxdata')
    data2 = load_data('Data/Map006.rxdata')
    data3 = load_data('Data/Map007.rxdata')
    data4 = load_data('Data/Map008.rxdata')
    data5 = load_data('Data/Map009.rxdata')
    map_array = [Yuki::Tilemap::MapData.new(data1, 5)]
    map_array.last.load_position(data1, :self, 0)
    map_array << Yuki::Tilemap::MapData.new(data2, 6)
    map_array.last.load_position(data1, :north, -10)
    map_array << Yuki::Tilemap::MapData.new(data2, 6)
    map_array.last.load_position(data1, :north, 10)
    map_array << Yuki::Tilemap::MapData.new(data4, 6)
    map_array.last.load_position(data1, :east, 0)
    map_array << Yuki::Tilemap::MapData.new(data2, 6)
    map_array.last.load_position(data1, :west, 0)
    map_array << Yuki::Tilemap::MapData.new(data3, 6)
    map_array.last.load_position(data1, :south, -11)
    map_array << Yuki::Tilemap::MapData.new(data5, 6)
    map_array.last.load_position(data1, :south, 11)
	t = Time.new
    map_array.each(&:load_tileset)
	puts "Tileset loading time: #{Time.new - t}s"
    @tilemap.map_datas = map_array
  end

  def update_inputs
    delta = 8
    @ox += delta if Input.press?(:RIGHT)
    @ox -= delta if Input.press?(:LEFT)
    @oy += delta if Input.press?(:DOWN)
    @oy -= delta if Input.press?(:UP)
  end

  def update_graphics
    t = Time.new
    @tilemap.ox = @ox
    @tilemap.oy = @oy
    @tilemap.update
    curr = Time.new - t
    @max = curr if curr > @max
    @min = curr if curr < @min
    @moy = (@moy * @count + curr) / (@count += 1)
    @viewport.sort_z
    print "\rMAX: #{@max} MIN: #{@min} MOY: #{@moy.ceil(5)} CURR: #{curr}           "
  end
end

$scene = NewRendererTest.new
