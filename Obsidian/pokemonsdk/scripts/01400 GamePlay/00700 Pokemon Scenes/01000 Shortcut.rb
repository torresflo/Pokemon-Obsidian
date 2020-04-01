#encoding: utf-8

#noyard
module GamePlay
  class Shortcut < Base
    #> Inclusions
    include ::Util::Item
    def initialize
      super
      @items = $bag.shortcuts
      @viewport = Viewport.create(:main, 10_000)
      @back = Sprite.new(@viewport).set_bitmap('Shortcut', :interface)
      @back.x = (320 - @back.bitmap.width) / 2
      @back.y = (240 - @back.bitmap.height) / 2 - 9
      delta_x = @back.bitmap.width / 3 + 1
      delta_y = @back.bitmap.height / 3 + 1
      @item_sprites = Array.new(PFM::Bag::SHORTCUT_AMOUNT) do |i|
        sp = Sprite.new(@viewport)
        sp.set_position(
          @back.x + (i & 0x01 == 1 ? (delta_x * (i & 0x02)) : delta_x) + 1,
          @back.y + (i & 0x01 == 1 ? delta_y : delta_y * i) + 1
        )
        sp.opacity = $bag.contain_item?(@items[i]) ? 255 : 96
        sp.set_bitmap(GameData::Item.icon(@items[i]), :icon) unless @items[i] == 0
=begin
        sprite(@items[i] != 0 ? GameData::Item.icon(@items[i]) : nil,
          @back.x + (i & 0x01 == 1 ? (delta_x * (i & 0x02)) : delta_x) + 1,
          @back.y + (i & 0x01 == 1 ? delta_y : delta_y * i) + 1,
          i, cache_name: :icon, 
          opacity: $bag.contain_item?(@items[i]) ? 255 : 96)
=end
        next(sp)
      end
    end

    def update
      return unless super
      if Input.trigger?(:B) or Input.trigger?(:Y)
        @running = false
      elsif(Input.trigger?(:UP))
        use(0)
      elsif(Input.trigger?(:DOWN))
        use(2)
      elsif(Input.trigger?(:RIGHT))
        use(3)
      elsif(Input.trigger?(:LEFT))
        use(1)
      end
    end

    def use(index)
      item_id = @items[index]
      return @running = false if item_id == 0 or !$bag.contain_item?(item_id)
      util_item_useitem(item_id)
    end

    def create_graphics
      # Skipped to prevent glitches
    end
  end
end
