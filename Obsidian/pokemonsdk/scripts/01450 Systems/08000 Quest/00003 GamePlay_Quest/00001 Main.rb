module GamePlay
  class QuestUI < BaseCleanUpdate::FrameBalanced
    # List of the categories of the quests
    # @return [Array<Symbol>]
    CATEGORIES = %i[primary secondary finished]
    # Initialize the whole Quest UI
    # @param quests [PFM::Quests] the quests to send to the Quest UI
    def initialize(quests = PFM.game_state.quests)
      super()
      @category = :primary # Possible categories are, in order, :primary, :secondary, :finished
      @quest_deployed = :compact
      @deployed_mode = :descr # Possible modes are :descr, :rewards and :objectives
      @last_key = nil
      @key_counter = 0
      @quests = quests
    end

    def update_graphics
      @base_ui.update_background_animation
      @composition.update
    end

    private

    def create_graphics
      super
      create_base_ui
      create_composition
      Graphics.sort_z
    end

    def create_viewport
      super
      @sub_viewport = Viewport.create(:main, 20_000)
      @sub_viewport2 = Viewport.create(27, 62, 272, 64, 21_000)
    end

    def create_base_ui
      @base_ui = UI::GenericBase.new(@viewport, button_texts)
    end

    def button_texts
      [ext_text(9006, 0), nil, nil, ext_text(9000, 115)]
    end

    # Return the text for the A button
    # @return [String]
    def a_button_text
      return @quest_deployed == :compact ? ext_text(9006, 0) : nil
    end

    # Return the text for the B button
    # @return [String]
    def b_button_text
      return @quest_deployed == :compact ? ext_text(9000, 115) : ext_text(9006, 4)
    end

    # Return the text for the X button
    # @return [String]
    def x_button_text
      hash = { descr: ext_text(9006, 2), rewards: ext_text(9006, 3), objectives: ext_text(9006, 1) }
      return hash[@deployed_mode]
    end

    def create_composition
      @composition = UI::Quest::Composition.new(@viewport, @sub_viewport, @sub_viewport2, @quests)
    end

    # Tell if the first button is currently deployed
    # @return [Boolean]
    def deployed?
      return @quest_deployed == :deployed
    end

    # Commute the variable telling if the first button is compacted or deployed
    def commute_quest_deployed
      @quest_deployed = (@quest_deployed == :compact ? :deployed : :compact)
    end
  end
end
