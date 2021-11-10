module GamePlay
  # Load game scene
  class Load < BaseCleanUpdate
    # Create a new GamePlay::Load scene
    def initialize
      super()
      GameData::Text.load
      @running = true
      @index = 0
      @all_saves = load_all_saves
      @all_saves.clear if @all_saves.size == 1 && @all_saves.first.nil?
      @mode = :waiting_input
    end

    def update_graphics
      @base_ui&.update_background_animation
      @signs.each(&:update)
    end

    # Tell if the Title should automatically create a new game instead
    # @return [Boolean]
    def should_make_new_game?
      @all_saves.empty?
    end

    private

    def create_graphics
      super
      create_base_ui
      create_shadow
      create_frame
      create_signs
    end

    def create_base_ui
      @base_ui = UI::GenericBase.new(@viewport, button_texts)
    end

    def button_texts
      [nil, nil, nil, ext_text(9000, 115)]
    end

    def create_shadow
      @shadow = Sprite.new(@viewport)
      @shadow.load('load/shadow_save', :interface)
      @shadow.visible = false
    end

    def create_frame
      @frame = Sprite.new(@viewport)
      @frame.load('load/frame_load', :interface)
    end

    def create_signs
      # @type [Array<UI::SaveSign>]
      @signs = (-1).upto(3).map do |i|
        UI::SaveSign.new(viewport, i)
      end
      load_sign_data
      @signs[1].animate_cursor
    end

    def load_sign_data
      max_save = Configs.save_config.maximum_save_count
      unlimited = Configs.save_config.unlimited_saves?
      @signs.each_with_index do |sign, i|
        index = i + @index - 1
        next sign.data = :hidden if index < 0 || index > @all_saves.size || (index >= max_save && !unlimited)

        data = @all_saves[index]
        next sign.data = index >= @all_saves.size ? :new : :corrupted unless data

        sign.save_index = index + 1
        sign.data = data
      end
    end
  end
end
