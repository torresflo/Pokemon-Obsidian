module BattleUI
  class TargetSelection < UI::Window
    # Offset X of the text to let the cursor display
    TEXT_OX = 16
    # Delta in X between two options
    DELTA_X = 96
    # Delta in Y between two options
    DELTA_Y = 16
    # Height of the border
    BORDER_HEIGHT = 16
    # Width of the border
    BORDER_WIDTH = 32
    # @return [Array, :cancel] the position (bank, position) of the choosen target
    attr_accessor :result
    # Create a new TargetSelection
    # @param viewport [LiteRGSS::Viewport]
    # @param launcher [PFM::PokemonBattler]
    # @param move [Battle::Move]
    # @param logic [Battle::Logic]
    def initialize(viewport, launcher, move, logic)
      @launcher = launcher
      @move = move
      @logic = logic
      @row_size = logic.battle_info.vs_type
      rc = viewport.rect
      width = current_width
      height = current_height
      super(viewport, (rc.width - width) / 2, (rc.height - height) / 2, width, height)
      @targets = move.battler_targets(launcher, logic)
      @mons = generate_mon_list
      @allowed_index = []
      load_background
      create_texts
      load_cursor
      @index = find_best_index
      update_cursor(true)
    end

    # Update the Window cursor
    def update
      return if validated?
      return validate if Input.trigger?(:A)
      return cancel if Input.trigger?(:B)
      last_index = @index
      if Input.repeat?(:RIGHT)
        @index = (@index + 1) % @row_size + @index / @row_size * @row_size
      elsif Input.repeat?(:LEFT)
        @index = (@index - 1) % @row_size + @index / @row_size * @row_size
      elsif Input.repeat?(:DOWN)
        @index = (@index + @row_size) % (2 * @row_size)
      elsif Input.repeat?(:UP)
        @index = (@index - @row_size) % (2 * @row_size)
      end
      update_cursor if last_index != @index
    end

    # If the player made a choice
    # @return [Boolean]
    def validated?
      !@result.nil?
    end

    private

    # Validate the player choice
    def validate
      if @allowed_index.include?(@index) && active
        @result = [@mons[@index].bank, @mons[@index].position]
      elsif @allowed_index.empty? # Auto target
        @result = [0, 0]
      else
        return $game_system.se_play($data_system.buzzer_se)
      end
      $game_system.se_play($data_system.decision_se)
    end

    # Cancel the player choice
    def cancel
      @result = :cancel
      $game_system.se_play($data_system.cancel_se)
    end

    # Update the cursor position
    # @param no_play [Boolean] if the cursor se should not be played
    def update_cursor(no_play = false)
      cursor_rect.set((@index % 2) * DELTA_X, (@index / 2) * DELTA_Y)
      $game_system.se_play($data_system.cursor_se) unless no_play
      self.active = !@move.no_choice_skill?
    end

    # Generate the list of Pokemon that is shown (including non-existing Pokemon as nil)
    def generate_mon_list
      top_list = @logic.foes_of(@launcher)
      bottom_list = [@launcher].concat(@logic.allies_of(@launcher))
      result_list = Array.new(@row_size) { |i| top_list.find { |mon| mon.position == i } }
      return result_list.concat(Array.new(@row_size) { |i| bottom_list.find { |mon| mon.position == i } })
    end

    # Create the text that represent each Pokemon
    def create_texts
      @mons.each_with_index do |mon, index|
        x = (index % @row_size) * DELTA_X
        y = (index / @row_size) * DELTA_Y
        next(add_text(x + TEXT_OX, y, DELTA_X, DELTA_Y, '---', color: 7)) unless mon
        color = @targets.include?(mon) ? 0 : 2
        @allowed_index << index if color != 2
        add_text(x + TEXT_OX, y, DELTA_X, DELTA_Y, mon.given_name, color: color)
      end
    end

    # Current width of the Window
    def current_width
      @row_size * DELTA_X + BORDER_WIDTH
    end

    # Current height of the window
    def current_height
      2 * DELTA_Y + BORDER_HEIGHT
    end

    # Find the best possible index as default index
    # @return [Integer]
    def find_best_index
      return @mons.index(@targets.first).to_i
    end

    # Load the background that helps to know which Pokemon can be aimed (and how)
    def load_background
      # @type [Array<Sprite>] List of sprite that should have their opacity waving
      @animated_sprites = []
      return # Right now this feature is shit, we'll see later
      random = @move.target == :random_foe
      if @move.no_choice_skill? && !random
        load_linked_background
      else
        image = 'battle/target_selector_helper'
        rect = random ? [0, 0, DELTA_X, DELTA_Y] : [DELTA_X, 0, DELTA_X, DELTA_Y]
        @mons.each_with_index do |mon, index|
          next unless @targets.include?(mon)
          sprite = push((index % @row_size) * DELTA_X, (index / @row_size) * DELTA_Y, image, rect: rect)
          @animated_sprites << sprite if random
        end
      end
    end

    # Load the background for moves that hits multiple target
    def load_linked_background
      image = 'battle/target_selector_helper'
      @mons.each_with_index do |mon, index|
        next unless @targets.include?(mon)
        rect = resolve_rect(index)
        @animated_sprites << push((index % @row_size) * DELTA_X, (index / @row_size) * DELTA_Y, image, rect: rect)
      end
    end

    # Function that will find the best rect to show the right part of the target_selector_helper image
    # @param index [Integer] index of the mon in the @mons array
    # @return [Array<Integer>] the sprite src_rect
    def resolve_rect(index)
      is_top_mon = index < @row_size
      is_middle_mon = (index % @row_size).between?(1, @row_size - 2)
      is_left_mon = (index % @row_size) == 0
      return resolve_rect_left(index, is_top_mon) if is_left_mon
      return resolve_rect_middle(index, is_top_mon) if is_middle_mon
      return resolve_rect_right(index, is_top_mon)
    end

    # TODO : Voir plutot une approche matricielle

    # Function that will resolve the src_rect of the target_selector_helper when the mon is on left position
    # @param index [Integer] index of the mon in the @mons array
    # @param is_top_mon [Boolean] info telling us if the Pokemon is in top row or not
    def resolve_rect_left(index, is_top_mon)
      mons = @mons
      targets = @targets
      has_right_link = (tmp_mon = mons[index + 1]) && targets.include?(tmp_mon)
      if is_top_mon
        has_bottom_link = (tmp_mon = mons[index + @row_size]) && targets.include?(tmp_mon)
        if has_bottom_link && has_right_link
          has_bottom_right_link = (tmp_mon = mons[index + @row_size + 1]) && targets.include?(tmp_mon)
          return [0, DELTA_Y * 2, DELTA_X, DELTA_Y] if has_bottom_right_link
          return [0, DELTA_Y * 4, DELTA_X, DELTA_Y]
        end
        return [0, DELTA_Y * 1, DELTA_X, DELTA_Y] if has_right_link
        return [DELTA_X * 1, 0, DELTA_X, DELTA_Y]
      elsif has_right_link
        has_top_link = (tmp_mon = mons[index - @row_size]) && targets.include?(tmp_mon)
        return [0, DELTA_Y * 3, DELTA_X, DELTA_Y] if has_top_link
        return [0, DELTA_Y * 1, DELTA_X, DELTA_Y]
      else
        has_top_link = (tmp_mon = mons[index - @row_size]) && targets.include?(tmp_mon)
        return [0, DELTA_Y * 5, DELTA_X, DELTA_Y] if has_top_link
        return [DELTA_X * 1, 0, DELTA_X, DELTA_Y]
      end
    end
  end
end
