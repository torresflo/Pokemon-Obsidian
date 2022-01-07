module UI
  module Storage
    # Stack responsive of showing a summary
    class Summary < UI::SpriteStack
      # Tell if the UI is reduced or not
      # @return [Boolean]
      attr_reader :reduced
      # Position of the summary depending on the state
      POSITION = [
        [210, 200], # Reduced
        [210, 10] # Developped
      ]
      # Position of the letter depending on the state
      LETTER_POSITION = [
        [1, 0], # Reduced
        [95, 15] # Developped
      ]
      # Time between each text transition
      TEXT_TRANSITION_TIME = 2
      # Create a new summary object
      # @param viewport [Viewport]
      # @param reduced [Boolean] if the UI is initially reduced or not
      def initialize(viewport, reduced)
        super(viewport, *POSITION[1]) # Initially in developped making easier to create the stack
        @reduced = reduced
        @invisible_if_egg = []
        # @type [Yuki::Animation::TimedAnimation]
        @animation = nil
        @last_time = Graphics.current_time
        @last_text = 0
        create_stack
        reset_text_visibility
        set_position(*POSITION[0]) if reduced
      end

      # Update the composition state
      def update
        @sprite&.update
        update_text_transition
        return if !@animation || @animation.done?

        @animation.update
      end

      # Set an object invisible if the Pokemon is an egg
      # @param object [#visible=] the object that is invisible if the Pokemon is an egg
      def no_egg(object)
        @invisible_if_egg << object
        return object
      end

      # Update the shown pokemon
      def data=(pokemon)
        super
        @pokemon = pokemon
        if @sprite.visible
          reset_text_visibility
          @invisible_if_egg.each { |sprite| sprite.visible = false } if @pokemon&.egg?
        end
      end

      # Tell if the animation is done
      # @return [boolean]
      def done?
        return true unless @animation

        return @animation.done?
      end

      # Reduce the UI (start animation)
      def reduce
        return if @reduced

        @animation = Yuki::Animation.move_discreet(0.2, self, *POSITION[1], *POSITION[0])
        @animation.start
        @reduced = true
      end

      # Show the UI (start animation)
      def show
        return unless @reduced

        @animation = Yuki::Animation.move_discreet(0.2, self, *POSITION[0], *POSITION[1])
        @animation.start
        @reduced = false
      end

      private

      # Function that updates the text transition
      def update_text_transition
        return unless @sprite.visible
        return if @pokemon.egg?

        if (Graphics.current_time - @last_time) >= TEXT_TRANSITION_TIME
          @transitionning_texts[@last_text].visible = false
          @last_text += 1
          @last_text %= @transitionning_texts.size
          @transitionning_texts[@last_text].visible = true
          @last_time = Graphics.current_time
        end
      end

      def create_stack
        create_background
        create_press_letter
        create_pokemon
      end

      def create_background
        add_background('pc/resume').set_z(5)
      end

      def create_press_letter
        add_sprite(*LETTER_POSITION[0], NO_INITIAL_IMAGE, :Y, type: UI::KeyShortcut).set_z(6)
        add_sprite(*LETTER_POSITION[1], NO_INITIAL_IMAGE, :Y, type: UI::KeyShortcut).set_z(6)
      end

      def create_pokemon
        no_egg @id_text = add_text(2, 17, 0, 16, :id_text, color: 10, type: SymText)
        @id_text.z = 6
        add_text(15, 25, 79, 15, :name, 1, color: 10, type: SymText).z = 6
        @sprite = add_sprite(55, 142, NO_INITIAL_IMAGE, type: UI::PokemonFaceSprite).set_z(6)
        add_text(15, 143, 79, 15, :given_name, 1, color: 10, type: SymText).z = 6
        no_egg add_sprite(96, 146, NO_INITIAL_IMAGE, type: UI::GenderSprite).set_z(6)
        no_egg add_sprite(62, 161, 'pc/lv_')
        no_egg add_text(76, 62, 0, 15, :level_text, color: 10, type: SymText)
        no_egg add_sprite(5, 172, NO_INITIAL_IMAGE, type: UI::Type1Sprite).set_z(6)
        no_egg add_sprite(57, 172, NO_INITIAL_IMAGE, type: UI::Type2Sprite).set_z(6)
        # Todo Add Symbols
        @transitionning_texts = [
          add_text(8, 189, 0, 15, :nature_text, color: 10, type: SymText),
          add_text(8, 189, 0, 15, :ability_name, color: 10, type: SymText),
          add_text(8, 189, 0, 15, :item_name, color: 10, type: SymText)
        ]
        @transitionning_texts.each { |text| no_egg(text) }
      end

      def reset_text_visibility
        @transitionning_texts.each do |tt|
          tt.visible = false
          tt.z = 6
        end
        @transitionning_texts[@last_text].visible = true
      end
    end
  end
end
