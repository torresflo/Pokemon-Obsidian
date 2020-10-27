module Yuki
  class Particle_Object
    ACTION_HANDLERS = {}
    ACTION_HANDLERS_ORDER = []

    # Add a new action handler
    # @param name [Symbol] name of the action
    # @param before [Symbol, nil] tell to put this handler before another handler
    def self.add_handler(name, before = nil, &block)
      unless ACTION_HANDLERS_ORDER.include?(name)
        index = before ? ACTION_HANDLERS_ORDER.index(before) : nil
        index ||= ACTION_HANDLERS_ORDER.size
        ACTION_HANDLERS_ORDER.insert(index, name)
      end
      ACTION_HANDLERS[name] = block
    end

    add_handler(:state) { |data| @state = data }
    add_handler(:on_chara_move_end) { |data| execute_action(data) if @character.movable? }
    add_handler(:zoom) { |data| @sprite.zoom = data * 1 }
    add_handler(:file) do |data|
      @sprite.bitmap = RPG::Cache.particle(data)
      @ox = @sprite.bitmap.width / 2
      @oy = @sprite.bitmap.height
    end
    add_handler(:position) { |data| @position_type = data }
    add_handler(:angle) { |data| @sprite.angle = data }
    add_handler(:add_z) { |data| @add_z = data }
    add_handler(:oy_offset) { |data| @oy_off = data + @params.fetch(:oy_offset, 0) }
    add_handler(:ox_offset) { |data| @ox_off = data + @params.fetch(:ox_offset, 0) }
    add_handler(:opacity) { |data| @sprite.opacity = data }
    add_handler(:se_play) { |data| Audio.se_play(*data) }
    add_handler(:se_player_play) { |data| Audio.se_play(*data) if @character == $game_player }
    add_handler(:wait) { |data| @wait_count = data.to_i }
    # Should be the last handlers : use the before argument when you add new handlers.
    add_handler(:chara) do |data|
      cw = @sprite.bitmap.width / 4
      ch = @sprite.bitmap.height / 4
      sx = @character.pattern * cw
      sy = (@character.direction - 2) / 2 * ch
      @sprite.src_rect.set(sx, sy, cw, ch)
      @ox = cw / 2
      @oy = ch / 2
    end
    add_handler(:rect) do |data|
      @sprite.src_rect.set(*data)
      @ox = data[2] / 2 # d[2] * @sprite.zoom_x
      @oy = data[3] # d[3] * @sprite.zoom_y
    end
  end
end
