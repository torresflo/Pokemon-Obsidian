module UI
  class QuestInformer < SpriteStack
    # Name of the ME to play
    ME_TO_PLAY = 'audio/me/rosa_keyitemobtained'
    # Base Y of the informer
    BASE_Y = 34
    # Offset Y between each informer
    OFFSET_Y = 24
    # Offset X between the two textes
    OFFSET_TEXT_X = 4
    # Lenght of a transition
    TRANSITION_LENGHT = 30
    # Lenght of the text move
    TEXT_MOVE_LENGHT = 30
    # Time the player has to read the text
    TEXT_REMAIN_LENGHT = 90
    # Create a new quest informer UI
    # @param viewport [Viewport]
    # @param name [String] Name of the quest
    # @param is_new [Boolean] if the quest is new
    # @param index [Integer] index of the quest
    def initialize(viewport, name, is_new, index)
      super(viewport, 0, BASE_Y + index * OFFSET_Y)
      @background = add_background('quest/quest_bg')
      @background.opacity = 0
      text = ext_text(9000, is_new ? 147 : 148)
      @info_text = add_text(0, 3, 0, 16, text, 0, 0, color: is_new ? 13 : 12)
      @name_text = add_text(@info_text.real_width + OFFSET_TEXT_X, 3, 0, 16, name, 0, 0)
      @max_x = (viewport.rect.width - @name_text.real_width) / 2
      @info_ini_x = @info_text.x = -(@max_x * 2 + @name_text.x)
      @name_ini_x = @name_text.x = -(@max_x * 2)
      @counter = 0
      play_sound(index)
    end

    # Update the animation for the quest informer
    def update
      if @counter < TRANSITION_LENGHT
        @background.opacity = (@counter + 1) * 255 / TRANSITION_LENGHT
      elsif @counter < PHASE2
        base_x = (@counter - TRANSITION_LENGHT + 1) * @max_x * 3 / TEXT_MOVE_LENGHT
        @info_text.x = base_x + @info_ini_x
        @name_text.x = base_x + @name_ini_x
      elsif @counter.between?(PHASE3, PHASE_END)
        @info_text.opacity =
          @name_text.opacity = @background.opacity = (PHASE_END - @counter) * 255 / TRANSITION_LENGHT
      end
      @counter += 1
    end

    # Tell if the animation is finished
    def done?
      (@background.disposed? || @background.opacity == 0) && @counter >= PHASE_END
    end

    private

    # Play the Quest got sound
    # @param index [Integer]
    def play_sound(index)
      Audio.me_play(ME_TO_PLAY) if index == 0
    end
  end
end

Graphics.on_start do
  UI::QuestInformer.class_eval do
    const_set :PHASE2, UI::QuestInformer::TRANSITION_LENGHT + UI::QuestInformer::TEXT_MOVE_LENGHT
    const_set :PHASE3, UI::QuestInformer::PHASE2 + UI::QuestInformer::TEXT_REMAIN_LENGHT
    const_set :PHASE_END, UI::QuestInformer::PHASE3 + UI::QuestInformer::TRANSITION_LENGHT
  end
end
